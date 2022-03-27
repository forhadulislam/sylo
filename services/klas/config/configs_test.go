package config

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

func Test_Configs(t *testing.T) {
	assert.NotEmpty(t, Config() ) 
}