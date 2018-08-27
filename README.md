# jcl_assess v0.1
- Author: Taewoong Yoo
- Website: http://ykhwong.x-y.net

## INTRODUCTION
This tool assesses JCLs. Since it also includes the custom cobol parser, the COBOL files will be also analyzed throughout the JCLs.

## Getting started
### Prerequisites
**1. Perl 5**
* **Unix-like operating system**

Type the following command for the manual installation:
```sh
$ yum -y install perl # CentOS/RHEL
```
```sh
$ sudo apt-get install perl # Ubuntu
```

### Downloading jcl_assess
Clone jcl_assess onto your local machine.
```sh
$ git clone https://github.com/ykhwong/jcl_assess.git
```

### Configuration
#### dir.lst
Go to the config directory and open the dir.lst. Specify the directory path for below.
```
PATH= # Main path to the source files (e.g, /src_path) -- Required
BIND= # Path to the BIND files (e.g, bind) -- Required
COPY= # Path to the COPY files (e.g, copy) -- Required
INCLUDE= # Path to the INCLUDE files (e.g, include) -- Required
JCL= # Path to the JCL files (e.g, jcl) -- Required
PARM= # Path to the PARM (e.g, parm) -- Required
PROC= # Path to the PROC (e.g, proc) -- Required
COBOL= # Path to the COBOL (e.g, cobol) -- Required
CICS= #Path to the CICS (e.g, cics) -- Optional
BMS= # Path to the BMS (e.g, bms) -- Optional
```
For example, if the PATH is set to /src_path and BIND is set to bind, the BIND directory that jcl_assess searches will become /src_path/bind.

#### Other lst files
Open the following files and add the target filenames that you are going to assess.

| File | - |
| ---- | ---- |
| bms.lst | Optional |
| cics.lst | Optional |
| input.lst | Optional |
| jcl.lst | Required |
| util.lst | Required |

You can add any mainframe-specific utilities to the util.lst.

### Place all JCLs and COBOLs into the directories
Copy all JCLs and COBOLs into the directories that you specified in the configuration file.

For example, if the PATH is set to /src_path and JCL is set to jcl in the dir.lst, then all JCL files must be copied to the /src_path/jcl directory.

### Assessment
After everything is set up correctly, you can start the assessment by running the following command.

```sh
$ sh jcl_assess.sh
```

The shell script will call the jcl_assess.pl which also may call the cobol_parser.pl given that the COBOL files are provided. All the results will be saved to the ./result directory.

#### Create a call-tree graph
In order to create a call-tree graph based on the result, please run the following script file.

```sh
$ sh show_result.sh
```

