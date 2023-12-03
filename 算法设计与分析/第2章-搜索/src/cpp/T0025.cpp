//
// Created by KingQAQuuu on 2023/11/15.
//
#include <stdio.h>

int n, m;                   // 点数n和边数m
const int N = 1e5 + 10;
int h[N], e[N], ne[N], idx; // 构建邻接矩阵
int q[N], d[N];             // 队列q和记录入度数组d

void add(int a, int b){     // 头插法
    e[idx] = b, ne[idx] = h[a], h[a] = idx++;
}

bool topsort(){
    int front = 0, rear = 0;
    for(int i = 1; i <= n; i++)             // 从编号1开始将所有入度为0的点入队
        if(!d[i])       q[rear++] = i;

    while(front < rear){
        int x = q[front++];
        for(int i = h[x]; i != -1; i = ne[i]){      // 获取入度为0的点的下一个邻接点
            int j = e[i];
            d[j]--;                                 // “删除”结点x后，与之相邻的结点j入度减一
            if(!d[j])       q[rear++] = j;      // 当结点j入度为0时，将其入队
        }
    }
    return rear == n;       // 当所有序列均入队时，说明是按照拓扑排序入队，反之则不为拓扑序列
}


int main(){
    scanf("%d%d", &n, &m);
    for(int i = 0; i <= n; i++)      h[i] = -1;     // 初始化邻接矩阵中的顶点表指向“空指针”
    while(m--){
        int a, b;       scanf("%d%d", &a, &b);
        add(a, b);
        d[b]++;         // 结点b的入度加一
    }
    if(topsort()){      // 若为拓扑排序，则输出拓扑序列
        for(int i = 0; i < n; i++)		printf("%d ", q[i]);
        puts("");
    }else
        puts("-1");

    return 0;
}
