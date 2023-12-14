#include<stdio.h>
#include<stdlib.h>
#include<pthread.h>
#include<unistd.h>

pthread_mutex_t chopstick[5];
void * philosopher(void *);
void eat(int);
int main()
{
	int i,a[5];
	pthread_t tid[5];
	
	for(i=0;i<5;i++)
		pthread_mutex_init(&chopstick[i], NULL);
		
	for(i=0;i<5;i++){
		a[i]=i;
		pthread_create(&tid[i],NULL,philosopher,(void *)&a[i]);
	}
	for(i=0;i<5;i++)
		pthread_join(tid[i],NULL);
	for(i=0;i<5;i++)
		pthread_mutex_destroy(&chopstick[i]);
}

void * philosopher(void * num)
{
	int phil=*(int *)num;
	printf("\nPhilosopher %d has entered room",phil);
	pthread_mutex_lock(&chopstick[phil]);
	sleep(1);
	pthread_mutex_lock(&chopstick[(phil+1)%5]);	
	eat(phil);
	sleep(2);
	printf("\nPhilosopher %d has finished eating",phil);
	pthread_mutex_unlock(&chopstick[(phil+1)%5]);
	pthread_mutex_unlock(&chopstick[phil]);
}

void eat(int phil)
{
	printf("\nPhilosopher %d is eating",phil);
}