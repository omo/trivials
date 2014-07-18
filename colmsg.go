package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"strings"
)

var _ = fmt.Println

var re_slash_comment = regexp.MustCompile("//(.*?)\\n")
var re_brancket_comment = regexp.MustCompile("/\\*(.*?)\\*/")
var re_whitespace = regexp.MustCompile("[[:space:]]+")

func FilterComments(text string) string {
	text = re_slash_comment.ReplaceAllString(text, "")
	text = re_whitespace.ReplaceAllString(text, " ")
	text = re_brancket_comment.ReplaceAllString(text, "")

	return text
}

var re_msg = regexp.MustCompile("IPC_(SYNC_)?MESSAGE_(CONTROL|ROUTED).+?\\)")
var message_lines = []string{}

func ReadHeader(name string) {
	bytes, _ := ioutil.ReadFile(name)
	text := FilterComments(string(bytes))
	found := re_msg.FindAllString(text, -1)
	message_lines = append(message_lines, found...)
}

var re_msg_decl = regexp.MustCompile("(.+?)\\((.+?)\\)")

func MessageToCols(message string) []string {
	match := re_msg_decl.FindStringSubmatch(message)

	if 0 == len(match) {
		fmt.Println("XXX:" + message + "\n")
	}

	type_name := match[1]
	params := strings.Split(match[2], ",")
	redundant_cols := append([]string{type_name}, params...)
	cols := []string{}
	for _, c := range redundant_cols {
		cols = append(cols, strings.Trim(c, " "))
	}

	return cols
}

func ToCSV(cols []string) string {
	return strings.Join(cols, ",")
}

func main() {
	for _, f := range os.Args[1:] {
		//print(f + "\n")
		ReadHeader(f)
	}

	if true {
		for _, m := range message_lines {
			//fmt.Printf("%s\n", ToCSV(MessageToCols(m)))
			fmt.Printf("%s\n", m)
		}
	}

	if false {
		for _, m := range message_lines {
			cols := MessageToCols(m)
			if 2 < len(cols) {
				fmt.Print(strings.Join(cols[2:], "\n"))
				fmt.Print("\n")
			}
		}

	}
}
