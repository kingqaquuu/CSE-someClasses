#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdint.h>

//传入虚拟地址vaddr
void mem_addr(unsigned long vaddr)
{
		
		printf("虚拟地址：%lx\n",vaddr);

		//获取系统设定的页面大小
		int pageSize = getpagesize();
		printf("页面大小：%x\n",pageSize);

		//计算此虚拟地址相对于0x0的经过页面数
		unsigned long v_pageIndex = vaddr / pageSize;
		printf("虚拟页号：%lx\n",v_pageIndex);

		unsigned long v_offset = v_pageIndex * sizeof(uint64_t);
		
		//页内偏移地址
		unsigned long page_offset = vaddr % pageSize;
		printf("页内偏移地址：%lx\n",page_offset);

		uint64_t item = 0;//存储对应项的值

		int fd = open("/proc/self/pagemap",O_RDONLY);
		if(fd == -1)//判断是否打开失败
		{
				printf("open /proc/self/pagemap error\n");
				return;
		}
		//将游标移动到相应位置，即对应项的起始地址且判断是否移动失败
		if(lseek(fd,v_offset,SEEK_SET) == -1)
		{
				printf("sleek errer\n");
				return;
		}
		//读取对应项的值，并存入item中，且判断读取数据位数是否正确
		if(read(fd,&item,sizeof(uint64_t)) != sizeof(uint64_t))
		{
				printf("read item error!\n");
				return;
		}
		//判断当前物理页是否在内存中，
		if((((uint64_t)1 <<63 )& item) == 0)
		{
				printf("page present is 0\n");
				return;
		}

		//获得物理页号，即取item的bit（0～54）
		uint64_t phy_pageIndex = (((uint64_t)1 << 55) - 1) & item;
		printf("物理页框号：%lx\n",phy_pageIndex);

		//获取物理地址
		unsigned long paddr = (phy_pageIndex * pageSize) + page_offset;
		printf("物理地址：%lx\n",paddr);
}

const int a = 100;//全局变量a
int main()
{
		int b =100;//局部变量b
		static int c =100;//局部静态变量c
		const int d =100;//局部常量d
		

		printf("全局常量a:\n");
		mem_addr((unsigned long)&a);

		printf("\n局部变量b:\n");        
		mem_addr((unsigned long)&b);
		
		printf("\n全局静态变量c:\n");
        mem_addr((unsigned long)&c);
		
		printf("\n局部常量d:\n");
		mem_addr((unsigned long)&d);
}
