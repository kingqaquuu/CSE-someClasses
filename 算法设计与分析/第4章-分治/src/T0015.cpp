//
// Created by KingQAQuuu on 2023/11/13.
//
#include "bits/stdc++.h"
using namespace std;
int a[100005];
int solve(int l,int r)
{
    if(l<1||r<1)return 0;
    if(l>r)return 0;
    if(l==r)return min(a[l],1);
    int m=1111111111,w=0;
    for(int i=l;i<=r;i++)
        if(a[i]<m)
        {
            m=a[i];
            w=i;
        }
    int j=a[w];
    for(int i=l;i<=r;i++)
        a[i]-=j;
    int lf=solve(l,w-1);
    int rg=solve(w+1,r);
    return min(j+lf+rg,r-l+1);
}
int main()
{
    int n;
    scanf("%d",&n);
    for(int i=1;i<=n;i++)
        scanf("%d",&a[i]);
    int ans=min(n,solve(1,n));
    printf("%d\n",ans);
    return 0;
}