import csv
import os
import xlwt
import numpy as np
import math

def get_data(alg, acc, path):
    pr = []
    sr = []
    num = []
    with open(os.path.join(path, "ALG%d" % alg, "BPR"), 'r') as f:
        f_csv = csv.reader(f)
        for row in f_csv:
            data = float(row[acc-1])
            pr.append(round(data * 1000) / 1000.0 )
    with open(os.path.join(path, "ALG%d" % alg, "BSR"), 'r') as f:
        f_csv = csv.reader(f)
        for row in f_csv:
            data = float(row[acc-1])
            sr.append(round(data * 1000) / 1000.0 )
    with open(os.path.join(path, "ALG%d" % alg, "et"), 'r') as f:
        f_csv = csv.reader(f)
        for row in f_csv:
            data = float(row[acc-3])
            num.append(data)
    return pr, sr, num

def get_table(algs, acc, path):
    pr_table = []
    sr_table = []
    num_table = []

    for alg in algs:
        [pr, sr, num] = get_data(alg, acc, path)
        pr_table.append(pr)
        sr_table.append(sr)
        num_table.append(num)
    return pr_table, sr_table, num_table

def gen_template(sheet, names):
    # three tables
    for i in range(3):
        start = i * (23+2)
        sheet.write_merge(start, start+1, 0, 0, 'Function \nIndex')
        for j in range(len(names)):
            sheet.write_merge(start, start, 2*j+1, 2*j+2, names[j])
            sheet.write(start+1, 2*j+1, 'PR')
            sheet.write(start+1, 2*j+2, 'SR')
        for j in range(1, 21):
            sheet.write(start+1+j, 0, j)
        sheet.write(start+22, 0, 'bprs')

def write_table(sheet, pr, sr, num, acc, base_idx):
    normal = xlwt.Font()
    black = xlwt.Font()
    normal.name = 'Arial'
    black.name = 'Arial'
    black.bold = True
    style = xlwt.XFStyle()
    bprs = [0 for i in range(len(pr))]

    start = acc * (23+2)+2
    for pro in range(20):
        p = [pp[pro] for pp in pr]
        s = [ss[pro] for ss in sr]
        ns = [nn[pro] for nn in num]
        max_p = max(p)
        max_s = max(s)
        for i in range(len(pr)):
            if sum(p) > 0 and p[i] == max_p:
                bprs[i] = bprs[i] + 1
                style.font = black
            else:
                style.font = normal

            if p[base_idx] == max_p and p[i] != max_p and i != base_idx and not math.isnan(ns[i]):
                data = "%.3lf(++)" % p[i] if ns[i] == 1 else "%.3lf(+)" % p[i]
            else:
                data = "%.3lf" % p[i]

            
            sheet.write(start+pro, 1+2*i, data, style)
            style.font = normal
            sheet.write(start+pro, 2+2*i, "%.3lf" % s[i], style)
    for i in range(len(pr)):
        style.font = black if bprs[i] == max(bprs) else normal
        sheet.write_merge(start+20, start+20, 1+2*i, 2+2*i, bprs[i], style)            


def gen_excel():
    path = os.path.dirname(os.path.realpath(__file__))
    book = xlwt.Workbook()
    sheet_name = ['mutate', 'minsize', 'nbc', 'alpha', 'balance', 'lambda', 'fai_KP']
    table_coloumns = [
        ['FBK-DE', 'FBK-DE-r', 'FBK-DE-k', 'FBK-DE-b', 'FBK-DE-rb', 'FBK-DE-n'],
        ['FBK-DE', 'FBK-DE-m10', 'FBK-DE-m15', 'FBK-DE-m30', 'FBK-DE-m60'],
        ['FBK-DE', 'FBK-DE-NBC'],
        ['FBK-DE-1/3', 'FBK-DE', 'FBK-DE-1', 'FBK-DE-2'],
        ['FBK-DE', 'no balance'],
        ['1.0', '2.0', '3.0'],
        ['1.0', '1.5', '2.0', '2.5']
    ]
    cmp_alg = [
        [1, 2, 3, 4, 5, 6],
        [1, 7, 8, 9, 10],
        [1, 15],
        [11, 1, 12, 13],
        [1, 14],
        [16, 1, 17],
        [19, 20, 1, 21]
    ]

    for i in range(len(sheet_name)):
        sheet = book.add_sheet(sheet_name[i])
        gen_template(sheet, table_coloumns[i])

        for j in range(3):
            [pr, sr, num] = get_table(cmp_alg[i], j+3, path)

            write_table(sheet, pr, sr, num, j, cmp_alg[i].index(1))
    book.save(os.path.join(path + r'\\fkp.xls'))

if __name__ == '__main__':
    gen_excel()