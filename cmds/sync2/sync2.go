package sync2

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/gofulljs/gbook/cmds/cmdutil"
	"github.com/gofulljs/gbook/global"
	"github.com/urfave/cli/v2"
	"golang.org/x/xerrors"
)

var Run = &cli.Command{
	Name:  global.CmdSync2,
	Usage: "sync2 gitbook, 不包含node_modules, suggest",
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:  "source",
			Usage: "gitbook数据源",
			Value: "https://github.com/gofulljs/gitbook/archive/refs/tags/3.2.3.tar.gz",
		},
		&cli.StringFlag{
			Name:  "proxy1",
			Usage: fmt.Sprintf(`自定义加速源(前缀+source), 不传采用以下\n%v`, global.Proxy1s),
		},
		&cli.StringFlag{
			Name:  "proxy2",
			Usage: `自定义加速源(替换https://github.com前缀)`,
		},
	},
	Action: func(cctx *cli.Context) error {

		_, bookHome, bookVersionPath, err := cmdutil.GetBookVars(cctx)
		if err != nil {
			return err
		}

		if checkGitbookIsExist(bookVersionPath) {
			return nil
		}

		downloadGitbook(bookHome, cctx.String("source"))

		return nodeInstall(bookVersionPath)
	},
}

// getRootPath get gitbook store path
func getRootPath() (string, error) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return "", xerrors.Errorf("%w", err)
	}
	return filepath.Join(homeDir, ".gitbook", "versions"), nil
}

// checkGitbookIsExist check gitbook is in $HOME dir exist
func checkGitbookIsExist(bookVersionPath string) bool {
	bookJsFullPath := filepath.Join(bookVersionPath, "bin", "gitbook.js")
	_, err := os.Stat(bookJsFullPath)
	if err != nil {
		if os.IsNotExist(err) {
			return false
		}
		panic(err)
	}

	nodeModulesPath := filepath.Join(bookVersionPath, "node_modules")
	_, err = os.Stat(nodeModulesPath)
	if err != nil {
		if os.IsNotExist(err) {
			return false
		}
		panic(err)
	}

	return true
}
