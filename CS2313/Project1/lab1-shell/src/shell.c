#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

#define MAX_ARGS 32
#define MAX_CMDS 8

typedef struct {
    char *argv[MAX_ARGS + 1];
    int argc;
} command_t;

typedef struct {
    command_t commands[MAX_CMDS];
    int count;
} pipeline_t;

void print_prompt(void) {
    if (!isatty(STDIN_FILENO) || !isatty(STDOUT_FILENO)) {
        return;
    }
    /* Print the prompt here - you can use ANSI escape codes
     *  to make it colorful if you like.
     */
    char cwd[1024];
    if (getcwd(cwd, sizeof(cwd)) != NULL) {
        char *home = getenv("HOME");
        char *display = cwd;
        if (home != NULL) {
            if (strcmp(cwd, home) == 0) {
                display = "~";
            } else if (strncmp(cwd, home, strlen(home)) == 0 && cwd[strlen(home)] == '/') {
                static char buf[1024];
                snprintf(buf, sizeof(buf), "~%s", cwd + strlen(home));
                display = buf;
            }
        }
        printf("\033[1;34m%s\033[1;37m:\033[0m ", display);
    }else{
        printf("\033[1;31m???\033[1;37m:\033[0m ");
    }
    fflush(stdout);
}

int read_line(char **line, size_t *capacity) {
    while (1) {
        errno = 0;
        ssize_t nread = getline(line, capacity, stdin);
        if (nread >= 0) {
            if (nread > 0 && (*line)[nread - 1] == '\n') {
                (*line)[nread - 1] = '\0';
            }
            return 1;
        }

        if (feof(stdin)) {
            return 0;
        }
        if (errno == EINTR) {
            clearerr(stdin);
            continue;
        }

        perror("getline");
        return 0;
    }
}

int is_blank_line(const char *line) {
    while (*line != '\0') {
        if (*line != ' ' && *line != '\t') {
            return 0;
        }
        ++line;
    }
    return 1;
}

/* Return 1 to exit the shell, 0 to continue. */
int handle_line(char *line) {
    /*
     * TODO(student):
     * - parse at most MAX_CMDS commands and MAX_ARGS args per command
     * - reject invalid pipelines before forking
     * - run builtins in the shell process
     * - on exec failure, print to stderr and call _exit(1) in the child
     * - close unused pipe fds in both parent and children
     * - wait for every child you create
     *
     * The structs above are only suggestions.
     */
    if (is_blank_line(line)) {
        return 0;
    }

    pipeline_t pipeline;
    pipeline.count = 0;

    char *start = line;
    while(1){
        char *pipe_pos = strchr(start, '|');
        char *segment;
        if(pipe_pos != NULL){
            *pipe_pos = '\0';
            segment = start;
            start = pipe_pos + 1;
        }else{
            segment = start;
        }
        if (is_blank_line(segment)) {
            fprintf(stderr, "syntax error\n");
            return 0;
        }
        if (pipeline.count >= MAX_CMDS) {
            fprintf(stderr, "too many commands\n");
            return 0;
        }

        command_t *cmd = &pipeline.commands[pipeline.count];
        cmd->argc = 0;
        char *saveptr2;
        char *token = strtok_r(segment, " \t", &saveptr2);
        while(token && cmd->argc < MAX_ARGS){
            cmd->argv[cmd->argc++] = token;
            token = strtok_r(NULL, " \t", &saveptr2);
        }
        if(token){
            fprintf(stderr, "too many arguments\n");
            return 0;
        }
        cmd->argv[cmd->argc] = NULL;
        pipeline.count++;
        if(pipe_pos == NULL)break;
    }

    if(pipeline.count==1){
        command_t *cmd = &pipeline.commands[0];
        if(strcmp(cmd->argv[0],"cd")==0){
            char *dir = cmd->argv[1] ? cmd->argv[1] : getenv("HOME");
            if (chdir(dir) == -1)perror("cd");
            return 0;
        }
        if(strcmp(cmd->argv[0],"exit")==0)return 1;
    }else{
        for(int i=0;i<pipeline.count;i++) {
            char *name=pipeline.commands[i].argv[0];
            if(strcmp(name,"cd")==0 || strcmp(name,"exit")==0) {
                fprintf(stderr, "%s: not supported in pipeline\n", name);
                return 0;
            }
        }
    }

    int num_pipes = pipeline.count - 1;
    int pipes[MAX_CMDS][2];
    for(int i=0;i<num_pipes;i++) {
        if(pipe(pipes[i])==-1){
            perror("pipe");//增强鲁棒性 可能会卡住 所以要关闭已经创建的
            for(int j=0;j<i;j++){
                close(pipes[j][0]);
                close(pipes[j][1]);
            }
            return 0;
        }
    }
    pid_t pids[MAX_CMDS];

    for(int i=0;i<pipeline.count;i++) {
        pid_t pid = fork();
        if(pid==-1){
            perror("fork");
            for(int j=0;j<num_pipes;j++){
                close(pipes[j][0]);
                close(pipes[j][1]);
            }
            for(int j=0;j<i;j++){
                waitpid(pids[j], NULL, 0);
            }
            return 0;
        }
        if(pid==0){
            if(i>0){
                dup2(pipes[i-1][0], STDIN_FILENO);
            }
            if(i<num_pipes){
                dup2(pipes[i][1], STDOUT_FILENO);
            }
            for(int j=0;j<num_pipes;j++){
                close(pipes[j][0]);
                close(pipes[j][1]);
            }
            execvp(pipeline.commands[i].argv[0], pipeline.commands[i].argv);
            perror(pipeline.commands[i].argv[0]);   
            _exit(1);
        }
        pids[i] = pid;
    }

    for(int i=0;i<num_pipes;i++) {
        close(pipes[i][0]);
        close(pipes[i][1]);
    }
    //关闭进程
    for(int i=0;i<pipeline.count;i++) {
        waitpid(pids[i], NULL, 0);
    }
    return 0;
}
int main(void) {
    char *line = NULL;
    size_t capacity = 0;

    while (1) {
        print_prompt();
        if (!read_line(&line, &capacity)) {
            putchar('\n');
            break;
        }
        if (handle_line(line)) {
            break;
        }
    }

    free(line);
    return 0;
}
