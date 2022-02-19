# Answers to questions from "Linux for Bioinformatics"

- **Q1: What is your home directory?**<br/>
A: 
```
/home/ubuntu
```

- **Q2. What is the output of this command?**<br/>
A: 
```
hello_world.txt
```

- **Q3. What is the output of each ls command?**<br/>
A:<br/>
```
my_folder:
my_folder2: hello_world.txt
```

- **Q4. What is the output of each?**<br/>
A:<br/>
```
my_folder:
my_folder2:
my_folder3: hello_world.txt
```

- **Q5. What editor did you use and what was the command to save your file changes?**<br/>
A: nano. ctrl + x, y, and then enter

- **Q6. What is the error?**<br/>
A:<br/>
```
Server refused our key
No supported authentication methods available (server sent: publickey)
```

- **Q7. What was the solution?**<br/>
A:<br/>
1. `su - sudouser`<br/>
2. generate new key pair, save private key, and copy public key to `~/.ssh/authorized_keys`<br/>
3. edit sudouser session by using the saved private key 

- **Q8. What does the `sudo docker run` part of the command do? And what does the `salmon swim` part of the command do?**<br/>
A:<br/>
`sudo docker run` downloads a test image and runs it in a container. `sudo` is necessary as there are no users added to the `docker` group.<br/>
`salmon swim` contains the docker image, where the `swim` command checks for the image and version of salmon

- **Q9. What is the output of this command?**<br/>
A: 
```
serveruser is not in the sudoers file. This incident will be reported.
```

- **Q10. What is the output of `flask --version`?**<br/>
A:<br/>
```
Python 3.9.7
Flask 2.0.2
Werkzeug 2.0.2
```

- **Q11. What is the output of `mamba -V`?**<br/>
A: 
```
conda 4.11.0
```

- **Q12. What is the output of `which python`?**<br/>
A: 
```
/home/serveruser/miniconda3/envs/py27/bin/python
```

- **Q13. What is the output of `which python` now?**<br/>
A: 
```
/home/serveruser/miniconda3/bin/python
```

- **Q14. What is the output of `salmon -h`?**<br/>
A:<br/>
```
salmon v1.4.0

Usage:  salmon -h|--help or
        salmon -v|--version or
        salmon -c|--cite or
        salmon [--no-version-check] <COMMAND> [-h | options]

Commands:
     index      : create a salmon index
     quant      : quantify a sample
     alevin     : single cell analysis
     swim       : perform super-secret operation
     quantmerge : merge multiple quantifications into a single file
```

- **Q15. What does the `-o athal.fa.gz` part of the command do?**<br/>
A: write downloaded file to be named to athal.fa.gz instead

- **Q16. What is a `.gz` file?**<br/>
A: gunzip compressed file

- **Q17. What does the `zcat` command do?**<br/>
A: open a compressed file for viewing without actually uncompressing it

- **Q18. What does the `head` command do?**<br/>
A: allows you to view the first n lines of a file

- **Q19. What does the number `100` signify in the command?**<br/>
A: see the first 100 lines in the file

- **Q20. What is `|` doing?**<br/>
A: chains commands together so that the output of one command is the input of the next command

- **Q21. What is a `.fa` file? What is this file format used for?**<br/>
A: fasta file. stores/contains sequences

- **Q22. What format are the downloaded sequencing reads in?**<br/>
A: .sra

- **Q23. WHat is the total size of the disk?**<br/>
A: 7.7G

- **Q24. How much space is remaining on the disk?**<br/>
A: 2.5G

- **Q25. What went wrong?**<br/>
A: not enough disk space to convert the reads to fastq

- **Q26. What was your solution?**<br/>
A: add --gzip flag to get a compressed fastq file 
