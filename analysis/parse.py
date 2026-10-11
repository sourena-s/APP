import re
from Bio.SeqUtils.CheckSum import crc64
recs={}; crcs={}
for f in ['raw1.txt','raw2.txt']:
    for blk in open(f).read().split('#ID ')[1:]:
        lines=blk.strip().split('\n'); hdr=lines[0].strip()
        sq=[l for l in lines[1:] if l.startswith('SQ')]
        seq=''.join(re.sub('[^A-Z]','',l) for l in lines[1:] if not l.startswith('SQ'))
        acc=hdr.split('|')[0].replace('CRC','')
        if sq:
            m=re.search(r'(\d+) AA;.*?([0-9A-F]{16}) CRC64',sq[0]); crcs[acc]=(int(m[1]),m[2])
        if seq: recs[acc]=(hdr,seq)
ok=[];bad=[]
for acc,(hdr,seq) in recs.items():
    L,c=crcs.get(acc,(None,None)); got=crc64(seq).replace('CRC-','')
    st='OK' if c==got and L==len(seq) else f'FAIL len {len(seq)}/{L} crc {got}/{c}'
    print(f'{acc:12} {hdr.split("|",1)[1]:40} {len(seq):4} {st}')
    (ok if st=='OK' else bad).append(acc)
with open('verified.fasta','w') as o:
    for acc in ok:
        hdr,seq=recs[acc]; _,g,sp=hdr.split('|')
        o.write(f'>{acc}|{g}|{sp}\n{seq}\n')
print(len(ok),'verified;',bad)
