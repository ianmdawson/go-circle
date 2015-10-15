package circle

import (
	"fmt"
	"os"
	"os/user"
	"path/filepath"

	"github.com/BurntSushi/toml"
)

type CircleConfig struct {
	Organizations map[string]organization
}

type organization struct {
	Token string
}

func getToken(org string) (string, error) {
	user, err := user.Current()
	if err != nil {
		return "", err
	}
	filename := filepath.Join(user.HomeDir, "cfg", "circleci")
	f, err := os.Open(filename)
	if err != nil {
		filename := filepath.Join(user.HomeDir, ".circlerc")
		f, err = os.Open(filename)
	}
	if err != nil {
		return "", err
	}
	var c CircleConfig
	_, err = toml.DecodeReader(f, &c)
	if err != nil {
		return "", err
	}
	if organization, ok := c.Organizations[org]; ok {
		return organization.Token, nil
	} else {
		return "", fmt.Errorf("Couldn't find organization %s in the config", org)
	}
}
