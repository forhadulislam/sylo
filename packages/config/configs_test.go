package config

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func Test_Configs(t *testing.T) {
	assert.NotEmpty(t, Config())
}
