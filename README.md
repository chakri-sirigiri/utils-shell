# utils-shell
Re-usable shell utilities 

## folder_stats
### How to Use
to calculate a folder stats, for all sub folders 1, level deep, and print files count, folders count and size of each folder., and at the end sum of all of them


Calculate statistics for a given folder by analyzing all its direct subfolders (1 level deep), printing the file count, folder count, and total size for each subfolder, and then displaying a summary of the total files, folders, and size across all subfolders and the main folder itself.

**Usage:** : 

`./folder_stats.sh /absolute/path/to/main`
Expected output

**Sample Output** 

```sh
📂 Processing folder: /absolute/path/to/main
----------------------------------------
sub1 1 0 1234
sub2 2 0 2345
----------------------------------------
Total 4 2 5678
```
(Where 1234, 2345, 5678 are folder sizes in bytes.)