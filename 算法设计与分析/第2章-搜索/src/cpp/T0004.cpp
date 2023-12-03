//
// Created by KingQAQuuu on 2023/11/14.
//
#include "bits/stdc++.h"
using namespace std;
int n,m,k;
int maze[6][6];
bool visited[6][6];
int dx[4]{1,0,-1,0};
int dy[4]{0,1,0,-1};
bool flag;
bool isValid(int x,int y){
    return x>=0&&x<m&&y>=0&&y<n&&!visited[x][y]&&!maze[x][y];
}
void dfs(int x,int y,int step){
    if (x==m-1&&y==n-1){
        if (step==k){
            flag=true;
        }
        return;
    }
    int nx,ny;
    visited[x][y]= true;
    for (int i = 0; i < 4; ++i) {
        nx=x+dx[i];
        ny=y+dy[i];
        if (isValid(nx,ny)){
            dfs(nx,ny,step+1);
        }
    }
    visited[x][y]= false;
}
int main(){
    cin>>n>>m>>k;
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < m; ++j) {
            cin>>maze[i][j];
        }
    }
    dfs(0,0,0);
    if (flag){
        printf("Yes");
    }else{
        printf("No");
    }
}