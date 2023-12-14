/*
 * @Author: kingqaquuu
 * @Date: 2023-12-05 18:09:32
 * @FilePath: \luogu_code\LruAndOpt.java
 */

import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.Scanner;


public class LruAndOpt {
    // 设置页面大小为10
    private final int pageSize = 10;

    public static void main(String[] args) {

        LruAndOpt lao = new LruAndOpt();
        System.out.println("页面大小为10,物理页框共3个");
        System.out.print("请输入访问序列的个数:");
        Scanner sc = new Scanner(System.in);
        int n = sc.nextInt();
        System.out.print("请输入随机数的限制:");
        int limit = sc.nextInt();
        final Random r = new Random();
        int[] A1 = new int[n];
        for (int i = 0; i < n; i++) {
            A1[i] = r.nextInt(limit);
        }
        int[] A2 = new int[n];
        for (int i = 0; i < n; i++) {
            A2[i] = i;
        }
        int[] A3 = new int[n];
        for (int i = 0; i < n; i++) {
            A3[i] = i % 100;
        }
        System.out.println("=================OPT算法=================");
        System.out.println("-----------------随机序列-----------------");
        lao.Opt(A1);
        System.out.println("-----------------顺序序列-----------------");
        lao.Opt(A2);
        System.out.println("-----------------循环序列-----------------");
        lao.Opt(A2);
        System.out.println("=================LRU算法=================");
        System.out.println("-----------------随机序列-----------------");
        lao.Lru(A1);
        System.out.println("-----------------顺序序列-----------------");
        lao.Lru(A2);
        System.out.println("-----------------循环序列-----------------");
        lao.Lru(A2);
    }

    public int getPageNumber(int address) {
        return address / pageSize;
    }

    public void Opt(int[] A) {
        int count = 0;
        int n = A.length;
        Map<Integer, Integer> pageMap = new HashMap<>();
        // 顺序访问
        for (int i = 0; i < n; i++) {
            int page = getPageNumber(A[i]);
            if (i == 0) {
                // 第一次访问一定缺页
                count++;
                pageMap.put(page, 1);
            } else {
                // 若不缺页则不作处理 下面处理缺页
                // 我们自己设定物理页框就3个
                if (!pageMap.containsKey(page)) {
                    count++;
                    if (pageMap.size() == 1) {
                        pageMap.put(page, 2);
                    } else if (pageMap.size() == 2) {
                        pageMap.put(page, 3);
                    } else {
                        // 要淘汰的页号是最远的将来第一次出现的那一页
                        // eliminate 要淘汰的页号
                        int eliminate = 0, latest = 0;
                        // 对于页表里的逻辑页k
                        for (int k : pageMap.keySet()) {
                            boolean found = false;
                            int time = 0;
                            for (int j = i + 1; j < n; j++) {
                                if (k == getPageNumber(A[j])) {
                                    found = true;
                                    time = j;
                                    break;
                                }
                            }
                            if (found) {
                                if (latest < time) {
                                    latest = time;
                                    eliminate = k;
                                }
                            } else {
                                //以后的元素都没有第k页的 直接淘汰
                                eliminate = k;
                                break;
                            }
                        }
                        int lzw = pageMap.get(eliminate);
                        pageMap.remove(eliminate);
                        pageMap.put(page, lzw);
                    }
                }
            }
        }
        System.out.println("访问次数:" + n + ",缺页次数:" + count + ",缺页率:"
                + String.format("%.2f", ((double) count / n * 100)) + "%");
    }

    public void Lru(int A[]) {
        int n = A.length;
        int count = 0;
        Map<Integer, Integer> pageMap = new HashMap<>();
        for (int i = 0; i < n; i++) {
            int page = getPageNumber(A[i]);
            if (i == 0) {
                // 第一次访问一定缺页
                count++;
                pageMap.put(page, 1);
            } else {
                // 若不缺页则不作处理 下面处理缺页
                if (!pageMap.containsKey(page)) {
                    count++;
                    if (pageMap.size() == 1) {
                        pageMap.put(page, 2);
                    } else if (pageMap.size() == 2) {
                        pageMap.put(page, 3);
                    }else{
                        // 要淘汰的页号是从当前页前一页开始往前扫描最后一个出现的
                        // eliminate 要淘汰的页号
                        int eliminate = 0, latest = Integer.MAX_VALUE;
                        int k = 0;
                        for (int j = i - 1;j >= 0;j--){
                            if (pageMap.containsKey(getPageNumber(A[j])) && latest > j){
                                latest = j;
                                k++;
                                eliminate = getPageNumber(A[j]);
                                if (k == 3){
                                    break;
                                }
                            }
                        }
                        int lzw = pageMap.get(eliminate);
                        pageMap.remove(eliminate);
                        pageMap.put(page, lzw);
                    }
                }
            }
        }
        System.out.println("访问次数:" + n + ",缺页次数:" + count + ",缺页率:"
                + String.format("%.2f", ((double) count / n * 100)) + "%");
    }
}
