package circle

import (
	"encoding/json"
	"fmt"
	"net/url"
	"testing"
	"time"
)

func TestCircleDuration(t *testing.T) {
	s := "345"
	var cd CircleDuration
	err := json.Unmarshal([]byte(s), &cd)
	if err != nil {
		t.Fatal(err)
	}
	expected := CircleDuration(345 * time.Millisecond)
	if cd != expected {
		t.Fatal(cd)
	}
}

func TestURL(t *testing.T) {
	s := "\"https://foo.com\""
	var u URL
	err := json.Unmarshal([]byte(s), &u)
	if err != nil {
		t.Fatal(err)
	}
	if u.Scheme != "https" {
		t.Fatalf("expected scheme to be 'https', url was %s", u)
	}
	t.Fatal()
}

func TestString(t *testing.T) {
	u, err := url.Parse("https://foo.com")
	if err != nil {
		t.Fatal(err)
	}
	fmt.Println(u.String())
	//cu := URL(*u)
	//fmt.Println(cu.String())
}
