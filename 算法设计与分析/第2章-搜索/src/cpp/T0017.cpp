//
// Created by KingQAQuuu on 2023/11/13.
//
#include "bits/stdc++.h"
using namespace std;
int ans,startBlcok,endBlock;
bool visited[1000000];
struct node{
    int num;
    int step;
};
queue<node> q;
void bfs(){
    q.push((node){startBlcok,0});
    while(!q.empty()){
        node temp;
        temp.num=q.front().num;
        temp.step=q.front().step;
        if(temp.num==endBlock){
            printf("%d\n",temp.step);
            return;
        }
        for (int i = 15; i >=0 ; i--) {
            int x=(15-i)/4,y=(15-i)%4,w=1<<i;
            int rz=1<<(i-1),dz=1<<(i-4);
            if(y<3&&(temp.num&w)!=(temp.num&rz))
            {
                if(!visited[temp.num^w^rz])
                {
                    visited[temp.num^w^rz]= true;
                    q.push((node){temp.num^w^rz,temp.step+1});
                }
            }
            if(x<3&&(temp.num&w)!=(temp.num&dz))
            {
                if(!visited[temp.num^w^dz])
                {
                    visited[temp.num^w^dz]= true;
                    q.push((node){temp.num^w^dz,temp.step+1});
                }
            }
        }
        q.pop();
    }
}
int main(){
    char c;
    for (int i = 15; i>=0; i--) {
        cin>>c;
        if (c=='1'){
            startBlcok+=1<<i;
        }
    }
    for (int i = 15; i>=0; i--) {
        cin>>c;
        if (c=='1'){
            endBlock+=1<<i;
        }
    }
    if (startBlcok==endBlock){
        printf("0\n");
    }
    else {
        bfs();
    }
    return 0;
}