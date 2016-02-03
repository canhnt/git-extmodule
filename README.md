# git-extmodule
git command to mimic the svn-externals feature

This script is based on the git-external in ruby version by Daniel Cestari 2010
(https://github.com/dcestari/git-external)

### Installation
#### Linux
- Add the `git-extmodule` to the $PATH
- Alternatively, run `git config --global alias.extmodule \!/path/to/git-extmodule`.
Note the exclamation mark.  This has the advantage that you
get some tab completion on the command line.

#### Windows
- Copy the `git-extmodule` to `%PROGRAMFILES%\Git\mingw64\libexec\git-core`


### Usages

#### Add a new external repository

```
git extmodule add <repository-url> <path> [<branch>]
```
#### Initialize (git clone) external repositories
```
git extmodule init
```

#### Update existing repositories to the latest version

```
git extmodule update
```

#### List external repositories

```
git extmodule list
```

#### Remove an external repository module
```
git extmodule rm <path>
```

#### Execute a command for all external repositories
```
git extmodule cmd '<command>'
```

## License

See the [LICENSE](LICENSE) file for license rights and limitations (Apache 2.0).
