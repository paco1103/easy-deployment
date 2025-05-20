# Easy Deploy

`easy_deploy.sh` is a simple script that lets you deploy multiple files with folder structure and backup the existing file in a single command

## Installation

1. Deploy the repository:
    ```
    git clone https://github.com/paco1103/easy-deployment.git
    ```
2. Navigate to the project directory:
    ```
    cd easy-deployment
    ```
3. Make the script executable:
    ```
    chmod 755 easy_deploy.sh
    ```

### Adding to Shortcut (macOS version)

To make the script easily accessible from anywhere on your Mac, you can create a symbolic link:

1. Move the script to a directory that's in your PATH, for example `/usr/local/bin`, and rename it to `ezdeploy`:
    ```
    sudo mv easy_deploy.sh /usr/local/bin/ezdeploy
    ```
2. Ensure the directory is in your PATH:
    ```
    echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bash_profile
    source ~/.bash_profile
    ```
    If you are using zsh, update your `.zshrc` file instead:
    ```
    echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
    source ~/.zshrc
    ```

Now you can run the script from anywhere using:
```
ezdeploy <source_directory> <target_directory> [--backup-separate <backup_directory>] [--deploy]
```

## Usage

To use the `easy_deploy.sh` script, run the following command:
```sh
./easy_deploy.sh <source_directory> <target_directory> [--backup-separate <backup_directory>] [--deploy]
```
## Example
```sh
./easy_deploy.sh /path/to/resource /path/to/destination
./easy_deploy.sh /path/to/resource /path/to/destination --backup-separate /path/for/backup
./easy_deploy.sh /path/to/resource /path/to/destination --backup-separate /path/for/backup --deploy
```

*The actual deployment is executed only when the ```--deploy``` flag is used.

## Backup Behavior

When deploying files, the script creates backups of existing target files before overwriting them. By default, if you do not provide the ```--backup-separate``` flag, each backup is created in the same directory as the original file with an appended extension that includes the date, like:  
```
source.txt.bak.yyyymmdd
```

Using the ```--backup-separate``` flag, you can specify a backup directory where all target files will be copied instead of storing backups in place. This approach helps keep the backup files separate from the main directory.

For example:
- Without ```--backup-separate```:  
    The file ```/path/to/destination/file.txt``` is backed up as ```/path/to/destination/file.txt.bak.20231005```

- With ```--backup-separate```:  
    All files from ```/path/to/destination``` are backed up into the specified backup directory, e.g., ```/backup/location```, preserving their filenames.

## Contributing

If you want to contribute to this project, please fork the repository and create a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.


## Watch More
Easy Clone: https://github.com/paco1103/easy-clone (A script for cloning multiple files with folder structure in a single command)