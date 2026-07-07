/**
 * thread_pool.c - Student implementation scaffold
 *
 * The public API and queue helpers are fixed. You still need to:
 * - define struct thread_pool
 * - FIFO task-queue operations
 * - choose the shared state and wake-up protocol your pool needs
 * - pool initialization and rollback on failure
 * - worker synchronization and lifecycle
 * - wait / destroy semantics
 *
 * You may add private static helpers in this file.
 */

#include <pthread.h>
#include <stdlib.h>

#include "task_queue.h"

struct thread_pool {
    pthread_t *threads;
    int worker_count;
    task_queue tasks;

    /*
     * TODO: add the shared state your design needs.
     *
     * A workable design must let submit(), worker threads, wait(), and destroy()
     * agree on:
     * - whether queued work exists,
     * - whether work is currently executing,
     * - whether shutdown has started,
     * - how sleepers are woken when those facts change.
     */
    pthread_mutex_t mutex;
    pthread_cond_t cond_work;
    pthread_cond_t cond_idle;
    int shutdown;
    int executing;
};

void task_queue_init(task_queue *queue) {
    queue->head = NULL;
    queue->tail = NULL;
    queue->count = 0;
}

/* TODO A: append one task at the tail while preserving head/tail/count. */
void task_queue_push(task_queue *queue, task *new_task) {
    queue->count++;
    new_task->next = NULL;
    if(!queue->head){
        queue->head = new_task;
        queue->tail = new_task;
    }else{
        queue->tail->next = new_task;
        queue->tail = new_task;
    }
}

/* TODO A: pop one task from the head and repair tail when the queue becomes empty. */
task *task_queue_pop(task_queue *queue) {
    if(!queue->head)return NULL;
    queue->count--;
    task *popout;
    popout = queue->head;
    if(!queue->count){
        queue->head=NULL;
        queue->tail=NULL;
        return popout;
    }
    queue->head = queue->head->next;
    return popout;
}

void task_queue_clear(task_queue *queue) {
    task *next_task;

    while ((next_task = task_queue_pop(queue)) != NULL) {
        free(next_task);
    }

    queue->head = NULL;
    queue->tail = NULL;
    queue->count = 0;
}

/*
 * TODO B: implement the worker loop.
 *
 * Required behavior:
 * - wait while no task is available
 * - exit cleanly after shutdown
 * - do not hold the synchronization lock that protects shared state
 *   while running the task
 * - after shutdown starts, do not begin any new queued task
 * - maintain shared state so wait/destroy semantics work
 */
void *thread_pool_worker_main(void *pool_arg) {
    thread_pool *pool = pool_arg;
    while(1){
        pthread_mutex_lock(&pool->mutex);
        while(pool->tasks.head==NULL&&!pool->shutdown){
            pthread_cond_wait(&pool->cond_work,&pool->mutex);
        }
        if(pool->shutdown){
            pthread_mutex_unlock(&pool->mutex);
            break;
        }
        task *t = task_queue_pop(&pool->tasks);
        if(t) pool->executing++;
        pthread_mutex_unlock(&pool->mutex);

        if(t){
            t->task_fn(t->task_arg);
            free(t);
            pthread_mutex_lock(&pool->mutex);
            pool->executing--;
            if (pool->tasks.count == 0 && pool->executing == 0){
            pthread_cond_broadcast(&pool->cond_idle); 
        }
            pthread_mutex_unlock(&pool->mutex);
        }
    }
    return NULL;
}

/*
 * TODO B: create the thread pool.
 *
 * You need:
 * - argument validation
 * - pool / thread-array allocation
 * - queue initialization
 * - initialization of the synchronization state your design needs
 * - worker creation
 * - rollback if any step fails after earlier steps succeeded
 */
thread_pool *thread_pool_create(int worker_count) {
    if(worker_count<=0)return NULL;
    thread_pool *pool = calloc(1,sizeof(thread_pool));

    if(!pool)goto cleanup;

    if(pthread_mutex_init(&pool->mutex,NULL))goto cleanup;
    if(pthread_cond_init(&pool->cond_work,NULL))goto cleanup;
    if(pthread_cond_init(&pool->cond_idle,NULL))goto cleanup;
    task_queue_init(&pool->tasks);
    pool->shutdown=0;

    pool->threads = calloc(worker_count,sizeof(pthread_t));
    if(!pool->threads)goto cleanup;
    for(int i=0;i<worker_count;i++){
        if(pthread_create(&pool->threads[i],NULL,thread_pool_worker_main,pool)){
            pool->worker_count=i;
            goto cleanup;
        }
    }
    pool->worker_count = worker_count;
    return pool;


cleanup:

    if(pool){
        if(pool->threads){
            pthread_mutex_lock(&pool->mutex);
            pool->shutdown = 1;
            pthread_cond_broadcast(&pool->cond_work); 
            pthread_mutex_unlock(&pool->mutex);
            for(int i=0;i<pool->worker_count;i++)
                pthread_join(pool->threads[i],NULL);
            free(pool->threads);
        }
        pthread_mutex_destroy(&pool->mutex);                                                                                                                        
        pthread_cond_destroy(&pool->cond_work);   
        pthread_cond_destroy(&pool->cond_idle);                                                                                                                       
        free(pool); 
    }
    return NULL;
}

/*
 * TODO B: submit a task safely.
 *
 * Required behavior:
 * - reject invalid input
 * - reject a pool that is already shutting down
 * - wake a waiting worker after a successful push
 * - submission may happen from inside a running worker task
 */
int thread_pool_submit(thread_pool *pool, thread_pool_task_fn task_fn, void *task_arg) {
    if(!pool||!task_fn)return -1;

    task *t = malloc(sizeof(task));
    if(!t)return -1;
    t->task_fn = task_fn;
    t->task_arg = task_arg;
    t->next = NULL;

    pthread_mutex_lock(&pool->mutex);

    if(pool->shutdown){
        pthread_mutex_unlock(&pool->mutex);
        free(t);
        return -1;
    }

    task_queue_push(&pool->tasks,t);
    pthread_cond_signal(&pool->cond_work);

    pthread_mutex_unlock(&pool->mutex);

    return 0;
}

/*
 * TODO C: block until the pool is idle.
 *
 * Idle means:
 * - the queue is empty
 * - no worker is still executing a task
 */
void thread_pool_wait(thread_pool *pool) { 
    pthread_mutex_lock(&pool->mutex);
    while(pool->tasks.count>0||pool->executing>0){
        pthread_cond_wait(&pool->cond_idle,&pool->mutex);
    }
    pthread_mutex_unlock(&pool->mutex);
}

/*
 * TODO D: destroy the pool.
 *
 * Required behavior:
 * - let already-started tasks finish
 * - drop not-yet-started tasks
 * - free resources after all workers exit
 */
void thread_pool_destroy(thread_pool *pool) {
    if (pool == NULL) {
        return;
    }

    /* Keep an explicit reference so the starter still builds with -Werror. */
    pthread_mutex_lock(&pool->mutex);
    pool->shutdown=1;
    pthread_cond_broadcast(&pool->cond_work);
    pthread_mutex_unlock(&pool->mutex);

    for(int i=0;i<pool->worker_count;i++)pthread_join(pool->threads[i],NULL);
    task_queue_clear(&pool->tasks);

    free(pool->threads);
    pthread_mutex_destroy(&pool->mutex);
    pthread_cond_destroy(&pool->cond_work);
    pthread_cond_destroy(&pool->cond_idle);
    free(pool);
}
