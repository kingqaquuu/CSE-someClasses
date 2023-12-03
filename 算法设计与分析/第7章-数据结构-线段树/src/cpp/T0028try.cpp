//
// Created by KingQAQuuu on 2023/12/1.
//
#include "bits/stdc++.h"
using namespace std;
#define ll long long
#define lc p<<1
#define rc p<<1|1
#define MAXN 1000001
struct Tree{
    ll l,r,sum,add;
}tr[MAXN*4];
ll n,m,a[MAXN];
void scan()
{
    cin>>n>>m;
    for(ll i=1;i<=n;i++)
        scanf("%lld",&a[i]);
}
void pushup(ll p){//向上更新
    tr[p].sum=tr[lc].sum+tr[rc].sum;
}
void pushdown(ll p){//向下更新
    if(tr[p].add){
        tr[lc].sum+=tr[p].add*(tr[lc].r-tr[lc].l+1);
        tr[rc].sum+=tr[p].add*(tr[rc].r-tr[lc].l+1);
        tr[lc].add+=tr[p].add;
        tr[rc].add+=tr[p].add;
        tr[p].add=0;
    }
}
void build(ll p,ll l,ll r){
    tr[p]={l,r,a[l],0};
    if(l==r) {//是叶子就返回
        return;
    }
    ll m=l+r>>1;//不是叶子就裂开
    build(lc,l,m);
    build(rc,m+1,r);
    pushup(p);
}
void update(ll p,ll x,ll y,ll k){
    if(x<=tr[p].l&&y>=tr[p].r){//覆盖则修改
        tr[p].sum+=(tr[p].r-tr[p].l+1)*k;
        tr[p].add+=k;
        return;
    }
    ll m=tr[p].l+tr[p].r>>1;//不覆盖则裂开
    pushdown(p);
    if(x<=m){
        update(lc,x,y,k);
    }
    if(y>m){
        update(rc,x,y,k);
    }
    pushup(p);
}
ll query(ll p,ll x,ll y){
    if(x<=tr[p].l&&y>=tr[p].r){
        return tr[p].sum;
    }
    ll m=tr[p].l+tr[p].r>>1;//不覆盖则裂开
    pushdown(p);
    ll sum = 0;
    if(x<=m){
        sum+= query(lc,x,y);
    }
    if(y>m){
        sum+= query(rc,x,y);
    }
    return sum;
}
int main(){
    ll a1,b,c,d,e,f;
    scan();
    build(1,1,n);
    while(m--){
        scanf("%lld",&a1);
        switch(a1)
        {
            case 1:{
                scanf("%lld%lld%lld",&b,&c,&d);
                update(1,b,c,d);
                break;
            }
            case 2:{
                scanf("%lld%lld",&e,&f);
                printf("%lld\n",query(1,e,f));
                break;
            }
        }
    }
    return 0;
}