//
// Created by KingQAQuuu on 2023/11/15
//
#include<bits/stdc++.h>
using namespace std;
int n,mm,ans=1e9;
int ss[130],vv[130];
inline void DFS(int v,int s,int m,int r,int h){
    if(2*(n-v)/r+s>ans)return;
    if(v+vv[m]>n)return;
    if(s+ss[m]>ans)return;
    if(m==0){
        if(v==n)ans=min(s,ans);
        return;
    }

    for(int i=r-1;i>=m;i--){
        if(m==mm)s=i*i;
        for(int j=min((n-v-vv[m-1])/(i*i),h-1);j>=m;j--){
            DFS(v+i*i*j,s+2*i*j,m-1,i,j);
        }
    }
}
int main(){
    cin>>n>>mm;
    ss[0]=0;vv[0]=0;
    for(int i=1;i<=17;i++){
        ss[i]=ss[i-1]+2*i*i;
        vv[i]=vv[i-1]+i*i*i;
    }
    DFS(0,0,mm,sqrt(n),sqrt(n));
    if(ans==1e9)cout<<0;
    else cout<<ans;
    return 0;
}
