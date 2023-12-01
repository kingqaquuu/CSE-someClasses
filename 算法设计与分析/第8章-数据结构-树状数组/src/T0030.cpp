//
// Created by KingQAQuuu on 2023/12/1.
//
#include "bits/stdc++.h"
using namespace std;
#define ll long long
#define MAXN 1000001
ll n,m,tree[MAXN*4];
int lowbit(ll k){
    return k&-k;
}
void add(ll x,ll k){
    while(x<=n){
        tree[x]+=k;
        x+= lowbit(x);
    }
}
ll sum(ll x){
    ll ans=0;
    while(x!=0){
        ans+=tree[x];
        x-= lowbit(x);
    }
    return ans;
}
int main(){
    cin>>n>>m;
    ll a,b,c;
    for (int i = 1; i <= n; ++i) {
        scanf("%lld",&a);
        add(i,a);
    }
    for (int i = 1; i <= m; ++i) {
        scanf("%lld%lld%lld",&a,&b,&c);
        if (a==1){
            add(b,c);
        }
        if(a==2){
            cout<<sum(c)-sum(b-1)<<endl;
        }
    }
}