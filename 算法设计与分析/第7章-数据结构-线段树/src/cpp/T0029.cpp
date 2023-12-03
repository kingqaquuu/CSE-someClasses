//
// Created by KingQAQuuu on 2023/12/1.
//
#include "bits/stdc++.h"
using namespace std;
#define ll long long
#define lc u<<1
#define rc u<<1|1
#define MAXN 1000001
struct Tree{
    ll l,r,sum,mul ,add;
}tr[MAXN*4];
ll n,m,p,a[MAXN];
void update(ll u) {
    tr[u].sum = (tr[lc].sum + tr[rc].sum) % p;
    return;
}
void scan()
{
    cin>>n>>m>>p;
    for(ll i=1;i<=n;i++)
        scanf("%lld",&a[i]);
}
void pushup(ll u){//向上更新
    tr[u].sum=(tr[lc].sum+tr[rc].sum)%p;
}
void build(ll u,ll l,ll r){
    tr[u]={l,r,a[l],1,0};
    if(l==r) {//是叶子就返回
        tr[u].sum=a[l]%p;
        return;
    }
    ll m=l+r>>1;//不是叶子就裂开
    build(lc,l,m);
    build(rc,m+1,r);
    pushup(u);
    return;
}
void pushdown(ll u){//向下更新
    tr[lc].sum = (tr[lc].sum * tr[u].mul + tr[u].add * (tr[lc].r - tr[lc].l + 1)) % p;
    tr[rc].sum = (tr[rc].sum * tr[u].mul + tr[u].add * (tr[rc].r - tr[rc].l + 1)) % p;

    tr[lc].mul = (tr[lc].mul * tr[u].mul) % p;
    tr[rc].mul = (tr[rc].mul * tr[u].mul) % p;

    tr[lc].add = (tr[lc].add * tr[u].mul + tr[u].add) % p;
    tr[rc].add = (tr[rc].add * tr[u].mul + tr[u].add) % p;

    tr[u].add = 0;
    tr[u].mul = 1;
    return;
}
void ChangeMul(ll u, ll x, ll y, ll k) { //区间乘法
    if (x <= tr[u].l && tr[u].r <= y) {
        tr[u].add = (tr[u].add * k) % p;
        tr[u].mul = (tr[u].mul * k) % p;
        tr[u].sum = (tr[u].sum * k) % p;
        return;
    }

    pushdown(u);
    int mid = (tr[u].l + tr[u].r) >> 1;
    if (x <= mid) ChangeMul(lc, x, y, k);
    if (y > mid) ChangeMul(rc, x, y, k);
    update(u);
    return;
}

void ChangeAdd(ll u, ll x, ll y, ll k) { //区间加法
    if (x <= tr[u].l && tr[u].r <= y) {
        tr[u].add = (tr[u].add + k) % p;
        tr[u].sum = (tr[u].sum + k * (tr[u].r - tr[u].l + 1)) % p;
        return;
    }

    pushdown(u);
    ll mid = (tr[u].l + tr[u].r) >> 1;
    if (x <= mid) ChangeAdd(lc, x, y, k);
    if (y > mid) ChangeAdd(rc, x, y, k);
    update(u);
    return;
}
ll AskRange(ll u, ll x, ll y) { //区间询问
    if (x <= tr[u].l && tr[u].r <= y) {
        return tr[u].sum;
    }

    pushdown(u);
    ll val = 0;
    ll mid = (tr[u].l + tr[u].r) >> 1;
    if (x <= mid) val = (val + AskRange(lc, x, y)) % p;
    if (y > mid) val = (val + AskRange(rc, x, y)) % p;
    return val;
}
int main(){
    ll op,x,y;
    scan();
    build(1,1,n);
    for (int i = 1; i <= m; i++){
        scanf("%lld%lld%lld",&op,&x,&y);
        if (op == 1) {
            ll k;
            scanf("%lld", &k);
            ChangeMul(1, x, y, k);
        }
        if (op == 2) {
            ll k;
            scanf("%lld", &k);
            ChangeAdd(1, x, y, k);
        }
        if (op == 3) {
            printf("%lld\n", AskRange(1, x, y));
        }
    }
    return 0;
}