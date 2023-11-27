//
// Created by KingQAQuuu on 2023/11/13.
//
#include "bits/stdc++.h"
using namespace std;
struct node{
    int deadline;
    int cutMoney;
};
int visted[501];
node xiaozhi[501];

int cmp(const node &a,const node &b){
    return a.cutMoney>b.cutMoney;
}
int main(){
    int m,n;
    scanf("%d %d",&m,&n);
    for (int i = 1; i <= n; ++i) {
        scanf("%d",&xiaozhi[i].deadline);
    }
    for (int i = 1; i <= n; ++i) {
        scanf("%d",&xiaozhi[i].cutMoney);
    }
    sort(xiaozhi+1,xiaozhi+1+n,cmp);
    int ans=0;
    for (int i = 1; i <= n; ++i) {
        int flag = 0;
        for (int j = xiaozhi[i].deadline; j ; j--) {
            if (visted[j]==0){
                visted[j]=1;
                flag=1;
                break;
            }
        }
        if (flag==0){
            for (int j = n; j  ; j--) {
                if (visted[j]==0){
                    visted[j]=1;
                    break;
                }
            }
            ans+=xiaozhi[i].cutMoney;
        }
    }
    printf("%d\n",m-ans);
    return 0;
}