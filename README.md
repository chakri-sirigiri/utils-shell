# utils-shell
Re-usable shell utilities 

## folder_stats
### How to Use
to calculate a folder stats, for all sub folders 1, level deep, and print files count, folders count and size of each folder., and at the end sum of all of them


Calculate statistics for a given folder by analyzing all its direct subfolders (1 level deep), printing the file count, folder count, and total size for each subfolder, and then displaying a summary of the total files, folders, and size across all subfolders and the main folder itself.

**Usage:** : 

`./folder_stats.sh /absolute/path/to/main`
Expected output

** Example Structure**
```
/absolute/path/to/main/
│── main.sh
│── .DS_Store      ❌ (Ignored)
│── temp.log       ❌ (Ignored)
│── sub1/
│   ├── sub1.sh
│   ├── data/
│   │   ├── data1.txt
│   │   ├── .DS_Store ❌ (Ignored)
│   │   └── temp.log ❌ (Ignored)
│   ├── .@__thumb/   ❌ (Ignored)
│   │   ├── thumb1.jpg
│   │   └── thumb2.jpg
│── sub2/
│   ├── sub2.sh
│   ├── backup/      ❌ (Ignored)
│   └── temp_folder/ ❌ (Ignored)
│       ├── ignored.txt
│       ├── ignored2.txt
```

**Expected Output** 

```sh
📂 Processing folder: /absolute/path/to/main
----------------------------------------
Folder,Files,Subfolders,Total Items,Size(Bytes)
sub1,1,1,2,12345
sub2,1,0,1,8567
----------------------------------------
Total,2,2,4,20912
```
