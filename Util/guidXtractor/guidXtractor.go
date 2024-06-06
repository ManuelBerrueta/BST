package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
)

func main() {
	// ANSI escape codes for colors
	green := "\033[32m"
	red := "\033[31m"
	reset := "\033[0m"

	if len(os.Args) < 2 {
		fmt.Println("Please provide a file name")
		return
	}

	fileName := os.Args[1]
	file, err := os.Open(fileName)
	if err != nil {
		fmt.Println(err)
		return
	}
	defer file.Close()

	guidRegex := regexp.MustCompile(`\b[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\b`)
	scanner := bufio.NewScanner(file)
	guids := make([]string, 0)

	for scanner.Scan() {
		line := scanner.Text()
		matches := guidRegex.FindAllString(line, -1)
		guids = append(guids, matches...)
	}

	if err := scanner.Err(); err != nil {
		fmt.Println(err)
	}

	fmt.Printf("%sFound %s%d%s %sGUIDs%s:\n", green, red, len(guids), reset, green, reset)
	for _, guid := range guids {
		fmt.Println(guid)
	}
}
