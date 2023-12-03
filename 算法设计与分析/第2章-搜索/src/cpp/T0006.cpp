#include "bits/stdc++.h"
using namespace std;
int n,ans=1000000;
int visited[1000000];
struct block{
    int x;
    int step;
};
queue<block> r;
int main() {
    scanf("%d",&n);
//BFS
    block start{1,0};

    r.push(start);//将起点入队
    visited[1]= true;
    while(!r.empty())
    {
        int x = r.front().x;
        if (x==n) {
            if (r.front().step<=ans){
                ans=r.front().step;
            }
        }
        if (r.front().x-1>=0&&!visited[r.front().x-1])
        {
            block temp;
            temp.x=r.front().x-1;
            temp.step=r.front().step+1;
            r.push(temp);
            visited[r.front().x-1]=1;
        }
        if (r.front().x+1<=n&&!visited[r.front().x+1])
        {
            block temp;
            temp.x=r.front().x+1;
            temp.step=r.front().step+1;
            r.push(temp);
            visited[r.front().x+1]=1;
        }
        if (r.front().x*2<=n&&!visited[r.front().x*2])
        {
            block temp;
            temp.x=r.front().x*2;
            temp.step=r.front().step+1;
            r.push(temp);
            visited[r.front().x*2]=1;
        }
        r.pop();
    }
    printf("%d",ans);
    return 0;
}
