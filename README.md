# git-extmodule
git command to mimic the svn-externals feature

This script is based on the git-external in ruby version by Daniel Cestari 2010
(https://github.com/dcestari/git-external)

### Installation
#### Linux
- Add the `git-extmodule.sh` to the $PATH
- Rename it to `git-extmodule`
- Add execute permission '+x'
#### Windows
- Copy the `git-extmodule.sh` to `%PROGRAMFILES%\Git\mingw64\libexec\git-core`
- Rename it to `git-extmodule`

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

