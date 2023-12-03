//
// Created by KingQAQuuu on 2023/11/13.
//
#include "bits/stdc++.h"
//每次都找最小的合并
using namespace std;
priority_queue<long long,vector<long long>,greater<long long> >pq1;
int main(){
    int n;
    long long power=0;
    scanf("%d",&n);
    if(n==1){
        long long x;
        cin>>x;
        cout<<x;
    }
    else{
        long long x;
        for (int i = 0; i < n; ++i) {
            cin>>x;
            pq1.push(x);
        }
        long long a,b;
        for (int i = 0; i < n-1; ++i) {
            a=pq1.top();
            pq1.pop();
            b=pq1.top();
            pq1.pop();
            power+=a+b;
            pq1.push(a+b);
        }
      cout<<power;

    }
}