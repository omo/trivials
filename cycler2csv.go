package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"strconv"
	"strings"
)

type CyclerLines struct {
	ColdTimes []string
	WarmTimes []string
}

type TimeRecord struct {
	Name  string
	Type  string
	Times []float32
}

func ReadCycler(name string) CyclerLines {
	bytes, _ := ioutil.ReadFile(name)
	text := string(bytes)
	lines := strings.Split(text, "\n")
	cold_times := []string{}
	warm_times := []string{}

	for _, l := range lines {
		if 0 == strings.Index(l, "RESULT cold_times") {
			cold_times = append(cold_times, l)
		}

		if 0 == strings.Index(l, "RESULT warm_times") {
			warm_times = append(warm_times, l)
		}
	}

	return CyclerLines{
		ColdTimes: cold_times,
		WarmTimes: warm_times,
	}
}

var namePattern = regexp.MustCompile(" (\\S+)=")
var listPattern = regexp.MustCompile("\\[(.+)\\]")

func ToRecord(line string, t string) TimeRecord {
	match := namePattern.FindStringSubmatch(line)
	list := listPattern.FindStringSubmatch(line)
	splitted := strings.Split(list[1], ",")
	times := []float32{}

	for _, s := range splitted {
		n, _ := strconv.ParseFloat(s, 32)
		times = append(times, float32(n))
	}

	return TimeRecord{
		Name:  match[1],
		Type:  t,
		Times: times,
	}
}

func ToRecordList(lines CyclerLines) []TimeRecord {
	records := []TimeRecord{}
	for _, c := range lines.ColdTimes {
		records = append(records, ToRecord(c, "cold"))

	}

	for _, w := range lines.WarmTimes {
		records = append(records, ToRecord(w, "warm"))
	}

	return records
}

func main() {
	filename := os.Args[1]
	tag := os.Args[2]
	cycler_lines := ReadCycler(filename)
	records := ToRecordList(cycler_lines)

	fmt.Printf("tag,name,type,time\n")
	for _, r := range records {
		for _, t := range r.Times {
			fmt.Printf("%s,%s,%s,%f\n", tag, r.Name, r.Type, t)
		}
	}
}
