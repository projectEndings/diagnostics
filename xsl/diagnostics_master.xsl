<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xi="http://www.w3.org/2001/XInclude" 
    xmlns:xh="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all" 
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml" 
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Started on:</xd:b> February 22, 2017</xd:p>
            <xd:p><xd:b>Authors:</xd:b> <xd:a href="http://mapoflondon.uvic.ca/TAKE1.htm">jtakeda</xd:a> and <xd:a href="http://mapoflondon.uvic.ca/HOLM3.htm">mholmes</xd:a>.</xd:p>
            <xd:p> This XSLT produces the necessary pages for the diagnostics report. It calls upon
                a statistics module and a diagnostics module. </xd:p>
        </xd:desc>
        <xd:param name="projectDirectory">
            <xd:p>The directory that contains all of the XML documents to be analyzed.</xd:p>
        </xd:param>
        <xd:param name="outputDirectory">
            <xd:p>The directory where any products from this transformation should be placed.</xd:p>
        </xd:param>
        <xd:param name="currDate">
            <xd:p>The current date in W3C format (YYYY-MM-DD).</xd:p>
        </xd:param>
    </xd:doc>

    <xsl:output method="xhtml" encoding="UTF-8" normalization-form="NFC" exclude-result-prefixes="#all"
         omit-xml-declaration="yes" />

    <xsl:param name="projectDirectory"/>
    <xsl:param name="outputDirectory"/>
    <xsl:param name="currDate"/>
    
  
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="projectCollection" type="variable"/>
            <xd:p>We use the project directory to create a collection of all the 
                XML documents in it. We'll process all of those documents.</xd:p></xd:desc>
    </xd:doc>
    <xsl:variable name="projectCollection"
        select="collection(concat('file:///', translate($projectDirectory, '\', '/'), '?select=*.xml;recurse=yes'))"/>
    
    <!--There are four root elements in TEI: TEI, teiCorpus, teiHeader, and text-->
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="teiDocs" type="variable"/>
            <xd:p>All TEI documents, starting at their root. Since TEI
                allows for four root elements (TEI, teiCorpus, teiHeader, and text [see <xd:a href="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/DS.html">here</xd:a>]), we have to account
                for all.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="teiDocs"
        select="$projectCollection/*[self::TEI | self::teiCorpus | self::teiHeader | self::text]"/>

    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="excludedAtts" type="variable"/>
            <xd:p>Although we basically check all attributes, there are some that we absolutely
                must explicitly exclude because they're bound to look like links and are 
                definitely not; and there are others that are quite common but are not URIs, so 
                we may save time by excluding them.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="excludedAtts" select="('matchPattern', 
        'replacementPattern', 'rend', 'style', 'age',
        'cert', 'cols', 'confidence', 'cRef', 'degree',
        'dim', 'direct', 'discrete', 'dur', 'dur-iso',
        'ed', 'encoding', 'evidence', 'extent', 'from', 'from-custom',
        'from-iso', 'height', 'ident', 'key', 'label',
        'lang', 'lemma', 'lrx', 'lry', 'match', 
        'mimeType', 'n', 'name', 'notAfter', 'notAfter-custom', 
        'notAfter-iso', 'notBefore', 'notBefore-custom', 'notBefore-iso', 'org', 
        'pattern', 'place', 'points', 'precision', 'quantity', 
        'real', 'reason', 'rhyme', 'role', 'rows', 
        'sample', 'scope', 'scribe', 'script', 'sex',
        'size', 'status', 'subtype', 'to', 'to-custom', 'to-iso',
        'type',  'ulx',  'uly',  'unit',  'width',  'when',  
        'when-custom',  'when-iso',  'xml:id',  'xml:lang',  'xml:space')"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="xmlLangRegex" type="variable"/>
            <xd:p>This ridiculous regex is generated from the <xd:a href="https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry">IANA Language 
                Subtag Registry</xd:a>, and is designed to check for incorrect values
                in @xml:lang. It does not guarantee that values make sense, but 
                it checks that they are constructed correctly from the available
                values for each component of a language subtag. It ignores private
                and extension tags that may appear at the end.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="xmlLangRegex">^((aa)|(ab)|(ae)|(af)|(ak)|(am)|(an)|(ar)|(as)|(av)|(ay)|(az)|(ba)|(be)|(bg)|(bh)|(bi)|(bm)|(bn)|(bo)|(br)|(bs)|(ca)|(ce)|(ch)|(co)|(cr)|(cs)|(cu)|(cv)|(cy)|(da)|(de)|(dv)|(dz)|(ee)|(el)|(en)|(eo)|(es)|(et)|(eu)|(fa)|(ff)|(fi)|(fj)|(fo)|(fr)|(fy)|(ga)|(gd)|(gl)|(gn)|(gu)|(gv)|(ha)|(he)|(hi)|(ho)|(hr)|(ht)|(hu)|(hy)|(hz)|(ia)|(id)|(ie)|(ig)|(ii)|(ik)|(in)|(io)|(is)|(it)|(iu)|(iw)|(ja)|(ji)|(jv)|(jw)|(ka)|(kg)|(ki)|(kj)|(kk)|(kl)|(km)|(kn)|(ko)|(kr)|(ks)|(ku)|(kv)|(kw)|(ky)|(la)|(lb)|(lg)|(li)|(ln)|(lo)|(lt)|(lu)|(lv)|(mg)|(mh)|(mi)|(mk)|(ml)|(mn)|(mo)|(mr)|(ms)|(mt)|(my)|(na)|(nb)|(nd)|(ne)|(ng)|(nl)|(nn)|(no)|(nr)|(nv)|(ny)|(oc)|(oj)|(om)|(or)|(os)|(pa)|(pi)|(pl)|(ps)|(pt)|(qu)|(rm)|(rn)|(ro)|(ru)|(rw)|(sa)|(sc)|(sd)|(se)|(sg)|(sh)|(si)|(sk)|(sl)|(sm)|(sn)|(so)|(sq)|(sr)|(ss)|(st)|(su)|(sv)|(sw)|(ta)|(te)|(tg)|(th)|(ti)|(tk)|(tl)|(tn)|(to)|(tr)|(ts)|(tt)|(tw)|(ty)|(ug)|(uk)|(ur)|(uz)|(ve)|(vi)|(vo)|(wa)|(wo)|(xh)|(yi)|(yo)|(za)|(zh)|(zu)|(aaa)|(aab)|(aac)|(aad)|(aae)|(aaf)|(aag)|(aah)|(aai)|(aak)|(aal)|(aam)|(aan)|(aao)|(aap)|(aaq)|(aas)|(aat)|(aau)|(aav)|(aaw)|(aax)|(aaz)|(aba)|(abb)|(abc)|(abd)|(abe)|(abf)|(abg)|(abh)|(abi)|(abj)|(abl)|(abm)|(abn)|(abo)|(abp)|(abq)|(abr)|(abs)|(abt)|(abu)|(abv)|(abw)|(abx)|(aby)|(abz)|(aca)|(acb)|(acd)|(ace)|(acf)|(ach)|(aci)|(ack)|(acl)|(acm)|(acn)|(acp)|(acq)|(acr)|(acs)|(act)|(acu)|(acv)|(acw)|(acx)|(acy)|(acz)|(ada)|(adb)|(add)|(ade)|(adf)|(adg)|(adh)|(adi)|(adj)|(adl)|(adn)|(ado)|(adp)|(adq)|(adr)|(ads)|(adt)|(adu)|(adw)|(adx)|(ady)|(adz)|(aea)|(aeb)|(aec)|(aed)|(aee)|(aek)|(ael)|(aem)|(aen)|(aeq)|(aer)|(aes)|(aeu)|(aew)|(aey)|(aez)|(afa)|(afb)|(afd)|(afe)|(afg)|(afh)|(afi)|(afk)|(afn)|(afo)|(afp)|(afs)|(aft)|(afu)|(afz)|(aga)|(agb)|(agc)|(agd)|(age)|(agf)|(agg)|(agh)|(agi)|(agj)|(agk)|(agl)|(agm)|(agn)|(ago)|(agp)|(agq)|(agr)|(ags)|(agt)|(agu)|(agv)|(agw)|(agx)|(agy)|(agz)|(aha)|(ahb)|(ahg)|(ahh)|(ahi)|(ahk)|(ahl)|(ahm)|(ahn)|(aho)|(ahp)|(ahr)|(ahs)|(aht)|(aia)|(aib)|(aic)|(aid)|(aie)|(aif)|(aig)|(aih)|(aii)|(aij)|(aik)|(ail)|(aim)|(ain)|(aio)|(aip)|(aiq)|(air)|(ais)|(ait)|(aiw)|(aix)|(aiy)|(aja)|(ajg)|(aji)|(ajn)|(ajp)|(ajt)|(aju)|(ajw)|(ajz)|(akb)|(akc)|(akd)|(ake)|(akf)|(akg)|(akh)|(aki)|(akj)|(akk)|(akl)|(akm)|(ako)|(akp)|(akq)|(akr)|(aks)|(akt)|(aku)|(akv)|(akw)|(akx)|(aky)|(akz)|(ala)|(alc)|(ald)|(ale)|(alf)|(alg)|(alh)|(ali)|(alj)|(alk)|(all)|(alm)|(aln)|(alo)|(alp)|(alq)|(alr)|(als)|(alt)|(alu)|(alv)|(alw)|(alx)|(aly)|(alz)|(ama)|(amb)|(amc)|(ame)|(amf)|(amg)|(ami)|(amj)|(amk)|(aml)|(amm)|(amn)|(amo)|(amp)|(amq)|(amr)|(ams)|(amt)|(amu)|(amv)|(amw)|(amx)|(amy)|(amz)|(ana)|(anb)|(anc)|(and)|(ane)|(anf)|(ang)|(anh)|(ani)|(anj)|(ank)|(anl)|(anm)|(ann)|(ano)|(anp)|(anq)|(anr)|(ans)|(ant)|(anu)|(anv)|(anw)|(anx)|(any)|(anz)|(aoa)|(aob)|(aoc)|(aod)|(aoe)|(aof)|(aog)|(aoh)|(aoi)|(aoj)|(aok)|(aol)|(aom)|(aon)|(aor)|(aos)|(aot)|(aou)|(aox)|(aoz)|(apa)|(apb)|(apc)|(apd)|(ape)|(apf)|(apg)|(aph)|(api)|(apj)|(apk)|(apl)|(apm)|(apn)|(apo)|(app)|(apq)|(apr)|(aps)|(apt)|(apu)|(apv)|(apw)|(apx)|(apy)|(apz)|(aqa)|(aqc)|(aqd)|(aqg)|(aql)|(aqm)|(aqn)|(aqp)|(aqr)|(aqt)|(aqz)|(arb)|(arc)|(ard)|(are)|(arh)|(ari)|(arj)|(ark)|(arl)|(arn)|(aro)|(arp)|(arq)|(arr)|(ars)|(art)|(aru)|(arv)|(arw)|(arx)|(ary)|(arz)|(asa)|(asb)|(asc)|(asd)|(ase)|(asf)|(asg)|(ash)|(asi)|(asj)|(ask)|(asl)|(asn)|(aso)|(asp)|(asq)|(asr)|(ass)|(ast)|(asu)|(asv)|(asw)|(asx)|(asy)|(asz)|(ata)|(atb)|(atc)|(atd)|(ate)|(atg)|(ath)|(ati)|(atj)|(atk)|(atl)|(atm)|(atn)|(ato)|(atp)|(atq)|(atr)|(ats)|(att)|(atu)|(atv)|(atw)|(atx)|(aty)|(atz)|(aua)|(aub)|(auc)|(aud)|(aue)|(auf)|(aug)|(auh)|(aui)|(auj)|(auk)|(aul)|(aum)|(aun)|(auo)|(aup)|(auq)|(aur)|(aus)|(aut)|(auu)|(auw)|(aux)|(auy)|(auz)|(avb)|(avd)|(avi)|(avk)|(avl)|(avm)|(avn)|(avo)|(avs)|(avt)|(avu)|(avv)|(awa)|(awb)|(awc)|(awd)|(awe)|(awg)|(awh)|(awi)|(awk)|(awm)|(awn)|(awo)|(awr)|(aws)|(awt)|(awu)|(awv)|(aww)|(awx)|(awy)|(axb)|(axe)|(axg)|(axk)|(axl)|(axm)|(axx)|(aya)|(ayb)|(ayc)|(ayd)|(aye)|(ayg)|(ayh)|(ayi)|(ayk)|(ayl)|(ayn)|(ayo)|(ayp)|(ayq)|(ayr)|(ays)|(ayt)|(ayu)|(ayx)|(ayy)|(ayz)|(aza)|(azb)|(azc)|(azd)|(azg)|(azj)|(azm)|(azn)|(azo)|(azt)|(azz)|(baa)|(bab)|(bac)|(bad)|(bae)|(baf)|(bag)|(bah)|(bai)|(baj)|(bal)|(ban)|(bao)|(bap)|(bar)|(bas)|(bat)|(bau)|(bav)|(baw)|(bax)|(bay)|(baz)|(bba)|(bbb)|(bbc)|(bbd)|(bbe)|(bbf)|(bbg)|(bbh)|(bbi)|(bbj)|(bbk)|(bbl)|(bbm)|(bbn)|(bbo)|(bbp)|(bbq)|(bbr)|(bbs)|(bbt)|(bbu)|(bbv)|(bbw)|(bbx)|(bby)|(bbz)|(bca)|(bcb)|(bcc)|(bcd)|(bce)|(bcf)|(bcg)|(bch)|(bci)|(bcj)|(bck)|(bcl)|(bcm)|(bcn)|(bco)|(bcp)|(bcq)|(bcr)|(bcs)|(bct)|(bcu)|(bcv)|(bcw)|(bcy)|(bcz)|(bda)|(bdb)|(bdc)|(bdd)|(bde)|(bdf)|(bdg)|(bdh)|(bdi)|(bdj)|(bdk)|(bdl)|(bdm)|(bdn)|(bdo)|(bdp)|(bdq)|(bdr)|(bds)|(bdt)|(bdu)|(bdv)|(bdw)|(bdx)|(bdy)|(bdz)|(bea)|(beb)|(bec)|(bed)|(bee)|(bef)|(beg)|(beh)|(bei)|(bej)|(bek)|(bem)|(beo)|(bep)|(beq)|(ber)|(bes)|(bet)|(beu)|(bev)|(bew)|(bex)|(bey)|(bez)|(bfa)|(bfb)|(bfc)|(bfd)|(bfe)|(bff)|(bfg)|(bfh)|(bfi)|(bfj)|(bfk)|(bfl)|(bfm)|(bfn)|(bfo)|(bfp)|(bfq)|(bfr)|(bfs)|(bft)|(bfu)|(bfw)|(bfx)|(bfy)|(bfz)|(bga)|(bgb)|(bgc)|(bgd)|(bge)|(bgf)|(bgg)|(bgi)|(bgj)|(bgk)|(bgl)|(bgm)|(bgn)|(bgo)|(bgp)|(bgq)|(bgr)|(bgs)|(bgt)|(bgu)|(bgv)|(bgw)|(bgx)|(bgy)|(bgz)|(bha)|(bhb)|(bhc)|(bhd)|(bhe)|(bhf)|(bhg)|(bhh)|(bhi)|(bhj)|(bhk)|(bhl)|(bhm)|(bhn)|(bho)|(bhp)|(bhq)|(bhr)|(bhs)|(bht)|(bhu)|(bhv)|(bhw)|(bhx)|(bhy)|(bhz)|(bia)|(bib)|(bic)|(bid)|(bie)|(bif)|(big)|(bij)|(bik)|(bil)|(bim)|(bin)|(bio)|(bip)|(biq)|(bir)|(bit)|(biu)|(biv)|(biw)|(bix)|(biy)|(biz)|(bja)|(bjb)|(bjc)|(bjd)|(bje)|(bjf)|(bjg)|(bjh)|(bji)|(bjj)|(bjk)|(bjl)|(bjm)|(bjn)|(bjo)|(bjp)|(bjq)|(bjr)|(bjs)|(bjt)|(bju)|(bjv)|(bjw)|(bjx)|(bjy)|(bjz)|(bka)|(bkb)|(bkc)|(bkd)|(bkf)|(bkg)|(bkh)|(bki)|(bkj)|(bkk)|(bkl)|(bkm)|(bkn)|(bko)|(bkp)|(bkq)|(bkr)|(bks)|(bkt)|(bku)|(bkv)|(bkw)|(bkx)|(bky)|(bkz)|(bla)|(blb)|(blc)|(bld)|(ble)|(blf)|(blg)|(blh)|(bli)|(blj)|(blk)|(bll)|(blm)|(bln)|(blo)|(blp)|(blq)|(blr)|(bls)|(blt)|(blv)|(blw)|(blx)|(bly)|(blz)|(bma)|(bmb)|(bmc)|(bmd)|(bme)|(bmf)|(bmg)|(bmh)|(bmi)|(bmj)|(bmk)|(bml)|(bmm)|(bmn)|(bmo)|(bmp)|(bmq)|(bmr)|(bms)|(bmt)|(bmu)|(bmv)|(bmw)|(bmx)|(bmy)|(bmz)|(bna)|(bnb)|(bnc)|(bnd)|(bne)|(bnf)|(bng)|(bni)|(bnj)|(bnk)|(bnl)|(bnm)|(bnn)|(bno)|(bnp)|(bnq)|(bnr)|(bns)|(bnt)|(bnu)|(bnv)|(bnw)|(bnx)|(bny)|(bnz)|(boa)|(bob)|(boe)|(bof)|(bog)|(boh)|(boi)|(boj)|(bok)|(bol)|(bom)|(bon)|(boo)|(bop)|(boq)|(bor)|(bot)|(bou)|(bov)|(bow)|(box)|(boy)|(boz)|(bpa)|(bpb)|(bpd)|(bpg)|(bph)|(bpi)|(bpj)|(bpk)|(bpl)|(bpm)|(bpn)|(bpo)|(bpp)|(bpq)|(bpr)|(bps)|(bpt)|(bpu)|(bpv)|(bpw)|(bpx)|(bpy)|(bpz)|(bqa)|(bqb)|(bqc)|(bqd)|(bqf)|(bqg)|(bqh)|(bqi)|(bqj)|(bqk)|(bql)|(bqm)|(bqn)|(bqo)|(bqp)|(bqq)|(bqr)|(bqs)|(bqt)|(bqu)|(bqv)|(bqw)|(bqx)|(bqy)|(bqz)|(bra)|(brb)|(brc)|(brd)|(brf)|(brg)|(brh)|(bri)|(brj)|(brk)|(brl)|(brm)|(brn)|(bro)|(brp)|(brq)|(brr)|(brs)|(brt)|(bru)|(brv)|(brw)|(brx)|(bry)|(brz)|(bsa)|(bsb)|(bsc)|(bse)|(bsf)|(bsg)|(bsh)|(bsi)|(bsj)|(bsk)|(bsl)|(bsm)|(bsn)|(bso)|(bsp)|(bsq)|(bsr)|(bss)|(bst)|(bsu)|(bsv)|(bsw)|(bsx)|(bsy)|(bta)|(btb)|(btc)|(btd)|(bte)|(btf)|(btg)|(bth)|(bti)|(btj)|(btk)|(btl)|(btm)|(btn)|(bto)|(btp)|(btq)|(btr)|(bts)|(btt)|(btu)|(btv)|(btw)|(btx)|(bty)|(btz)|(bua)|(bub)|(buc)|(bud)|(bue)|(buf)|(bug)|(buh)|(bui)|(buj)|(buk)|(bum)|(bun)|(buo)|(bup)|(buq)|(bus)|(but)|(buu)|(buv)|(buw)|(bux)|(buy)|(buz)|(bva)|(bvb)|(bvc)|(bvd)|(bve)|(bvf)|(bvg)|(bvh)|(bvi)|(bvj)|(bvk)|(bvl)|(bvm)|(bvn)|(bvo)|(bvp)|(bvq)|(bvr)|(bvt)|(bvu)|(bvv)|(bvw)|(bvx)|(bvy)|(bvz)|(bwa)|(bwb)|(bwc)|(bwd)|(bwe)|(bwf)|(bwg)|(bwh)|(bwi)|(bwj)|(bwk)|(bwl)|(bwm)|(bwn)|(bwo)|(bwp)|(bwq)|(bwr)|(bws)|(bwt)|(bwu)|(bww)|(bwx)|(bwy)|(bwz)|(bxa)|(bxb)|(bxc)|(bxd)|(bxe)|(bxf)|(bxg)|(bxh)|(bxi)|(bxj)|(bxk)|(bxl)|(bxm)|(bxn)|(bxo)|(bxp)|(bxq)|(bxr)|(bxs)|(bxu)|(bxv)|(bxw)|(bxx)|(bxz)|(bya)|(byb)|(byc)|(byd)|(bye)|(byf)|(byg)|(byh)|(byi)|(byj)|(byk)|(byl)|(bym)|(byn)|(byo)|(byp)|(byq)|(byr)|(bys)|(byt)|(byv)|(byw)|(byx)|(byy)|(byz)|(bza)|(bzb)|(bzc)|(bzd)|(bze)|(bzf)|(bzg)|(bzh)|(bzi)|(bzj)|(bzk)|(bzl)|(bzm)|(bzn)|(bzo)|(bzp)|(bzq)|(bzr)|(bzs)|(bzt)|(bzu)|(bzv)|(bzw)|(bzx)|(bzy)|(bzz)|(caa)|(cab)|(cac)|(cad)|(cae)|(caf)|(cag)|(cah)|(cai)|(caj)|(cak)|(cal)|(cam)|(can)|(cao)|(cap)|(caq)|(car)|(cas)|(cau)|(cav)|(caw)|(cax)|(cay)|(caz)|(cba)|(cbb)|(cbc)|(cbd)|(cbe)|(cbg)|(cbh)|(cbi)|(cbj)|(cbk)|(cbl)|(cbn)|(cbo)|(cbq)|(cbr)|(cbs)|(cbt)|(cbu)|(cbv)|(cbw)|(cby)|(cca)|(ccc)|(ccd)|(cce)|(ccg)|(cch)|(ccj)|(ccl)|(ccm)|(ccn)|(cco)|(ccp)|(ccq)|(ccr)|(ccs)|(cda)|(cdc)|(cdd)|(cde)|(cdf)|(cdg)|(cdh)|(cdi)|(cdj)|(cdm)|(cdn)|(cdo)|(cdr)|(cds)|(cdy)|(cdz)|(cea)|(ceb)|(ceg)|(cek)|(cel)|(cen)|(cet)|(cfa)|(cfd)|(cfg)|(cfm)|(cga)|(cgc)|(cgg)|(cgk)|(chb)|(chc)|(chd)|(chf)|(chg)|(chh)|(chj)|(chk)|(chl)|(chm)|(chn)|(cho)|(chp)|(chq)|(chr)|(cht)|(chw)|(chx)|(chy)|(chz)|(cia)|(cib)|(cic)|(cid)|(cie)|(cih)|(cik)|(cim)|(cin)|(cip)|(cir)|(ciw)|(ciy)|(cja)|(cje)|(cjh)|(cji)|(cjk)|(cjm)|(cjn)|(cjo)|(cjp)|(cjr)|(cjs)|(cjv)|(cjy)|(cka)|(ckb)|(ckh)|(ckl)|(ckn)|(cko)|(ckq)|(ckr)|(cks)|(ckt)|(cku)|(ckv)|(ckx)|(cky)|(ckz)|(cla)|(clc)|(cld)|(cle)|(clh)|(cli)|(clj)|(clk)|(cll)|(clm)|(clo)|(clt)|(clu)|(clw)|(cly)|(cma)|(cmc)|(cme)|(cmg)|(cmi)|(cmk)|(cml)|(cmm)|(cmn)|(cmo)|(cmr)|(cms)|(cmt)|(cna)|(cnb)|(cnc)|(cng)|(cnh)|(cni)|(cnk)|(cnl)|(cno)|(cns)|(cnt)|(cnu)|(cnw)|(cnx)|(coa)|(cob)|(coc)|(cod)|(coe)|(cof)|(cog)|(coh)|(coj)|(cok)|(col)|(com)|(con)|(coo)|(cop)|(coq)|(cot)|(cou)|(cov)|(cow)|(cox)|(coy)|(coz)|(cpa)|(cpb)|(cpc)|(cpe)|(cpf)|(cpg)|(cpi)|(cpn)|(cpo)|(cpp)|(cps)|(cpu)|(cpx)|(cpy)|(cqd)|(cqu)|(cra)|(crb)|(crc)|(crd)|(crf)|(crg)|(crh)|(cri)|(crj)|(crk)|(crl)|(crm)|(crn)|(cro)|(crp)|(crq)|(crr)|(crs)|(crt)|(crv)|(crw)|(crx)|(cry)|(crz)|(csa)|(csb)|(csc)|(csd)|(cse)|(csf)|(csg)|(csh)|(csi)|(csj)|(csk)|(csl)|(csm)|(csn)|(cso)|(csq)|(csr)|(css)|(cst)|(csu)|(csv)|(csw)|(csy)|(csz)|(cta)|(ctc)|(ctd)|(cte)|(ctg)|(cth)|(ctl)|(ctm)|(ctn)|(cto)|(ctp)|(cts)|(ctt)|(ctu)|(ctz)|(cua)|(cub)|(cuc)|(cug)|(cuh)|(cui)|(cuj)|(cuk)|(cul)|(cum)|(cuo)|(cup)|(cuq)|(cur)|(cus)|(cut)|(cuu)|(cuv)|(cuw)|(cux)|(cvg)|(cvn)|(cwa)|(cwb)|(cwd)|(cwe)|(cwg)|(cwt)|(cya)|(cyb)|(cyo)|(czh)|(czk)|(czn)|(czo)|(czt)|(daa)|(dac)|(dad)|(dae)|(daf)|(dag)|(dah)|(dai)|(daj)|(dak)|(dal)|(dam)|(dao)|(dap)|(daq)|(dar)|(das)|(dau)|(dav)|(daw)|(dax)|(day)|(daz)|(dba)|(dbb)|(dbd)|(dbe)|(dbf)|(dbg)|(dbi)|(dbj)|(dbl)|(dbm)|(dbn)|(dbo)|(dbp)|(dbq)|(dbr)|(dbt)|(dbu)|(dbv)|(dbw)|(dby)|(dcc)|(dcr)|(dda)|(ddd)|(dde)|(ddg)|(ddi)|(ddj)|(ddn)|(ddo)|(ddr)|(dds)|(ddw)|(dec)|(ded)|(dee)|(def)|(deg)|(deh)|(dei)|(dek)|(del)|(dem)|(den)|(dep)|(deq)|(der)|(des)|(dev)|(dez)|(dga)|(dgb)|(dgc)|(dgd)|(dge)|(dgg)|(dgh)|(dgi)|(dgk)|(dgl)|(dgn)|(dgo)|(dgr)|(dgs)|(dgt)|(dgu)|(dgw)|(dgx)|(dgz)|(dha)|(dhd)|(dhg)|(dhi)|(dhl)|(dhm)|(dhn)|(dho)|(dhr)|(dhs)|(dhu)|(dhv)|(dhw)|(dhx)|(dia)|(dib)|(dic)|(did)|(dif)|(dig)|(dih)|(dii)|(dij)|(dik)|(dil)|(dim)|(din)|(dio)|(dip)|(diq)|(dir)|(dis)|(dit)|(diu)|(diw)|(dix)|(diy)|(diz)|(dja)|(djb)|(djc)|(djd)|(dje)|(djf)|(dji)|(djj)|(djk)|(djl)|(djm)|(djn)|(djo)|(djr)|(dju)|(djw)|(dka)|(dkk)|(dkl)|(dkr)|(dks)|(dkx)|(dlg)|(dlk)|(dlm)|(dln)|(dma)|(dmb)|(dmc)|(dmd)|(dme)|(dmg)|(dmk)|(dml)|(dmm)|(dmn)|(dmo)|(dmr)|(dms)|(dmu)|(dmv)|(dmw)|(dmx)|(dmy)|(dna)|(dnd)|(dne)|(dng)|(dni)|(dnj)|(dnk)|(dnn)|(dnr)|(dnt)|(dnu)|(dnv)|(dnw)|(dny)|(doa)|(dob)|(doc)|(doe)|(dof)|(doh)|(doi)|(dok)|(dol)|(don)|(doo)|(dop)|(doq)|(dor)|(dos)|(dot)|(dov)|(dow)|(dox)|(doy)|(doz)|(dpp)|(dra)|(drb)|(drc)|(drd)|(dre)|(drg)|(drh)|(dri)|(drl)|(drn)|(dro)|(drq)|(drr)|(drs)|(drt)|(dru)|(drw)|(dry)|(dsb)|(dse)|(dsh)|(dsi)|(dsl)|(dsn)|(dso)|(dsq)|(dta)|(dtb)|(dtd)|(dth)|(dti)|(dtk)|(dtm)|(dtn)|(dto)|(dtp)|(dtr)|(dts)|(dtt)|(dtu)|(dty)|(dua)|(dub)|(duc)|(dud)|(due)|(duf)|(dug)|(duh)|(dui)|(duj)|(duk)|(dul)|(dum)|(dun)|(duo)|(dup)|(duq)|(dur)|(dus)|(duu)|(duv)|(duw)|(dux)|(duy)|(duz)|(dva)|(dwa)|(dwl)|(dwr)|(dws)|(dwu)|(dww)|(dwy)|(dya)|(dyb)|(dyd)|(dyg)|(dyi)|(dym)|(dyn)|(dyo)|(dyu)|(dyy)|(dza)|(dzd)|(dze)|(dzg)|(dzl)|(dzn)|(eaa)|(ebg)|(ebk)|(ebo)|(ebr)|(ebu)|(ecr)|(ecs)|(ecy)|(eee)|(efa)|(efe)|(efi)|(ega)|(egl)|(ego)|(egx)|(egy)|(ehu)|(eip)|(eit)|(eiv)|(eja)|(eka)|(ekc)|(eke)|(ekg)|(eki)|(ekk)|(ekl)|(ekm)|(eko)|(ekp)|(ekr)|(eky)|(ele)|(elh)|(eli)|(elk)|(elm)|(elo)|(elp)|(elu)|(elx)|(ema)|(emb)|(eme)|(emg)|(emi)|(emk)|(emm)|(emn)|(emo)|(emp)|(ems)|(emu)|(emw)|(emx)|(emy)|(ena)|(enb)|(enc)|(end)|(enf)|(enh)|(enl)|(enm)|(enn)|(eno)|(enq)|(enr)|(enu)|(env)|(enw)|(enx)|(eot)|(epi)|(era)|(erg)|(erh)|(eri)|(erk)|(ero)|(err)|(ers)|(ert)|(erw)|(ese)|(esg)|(esh)|(esi)|(esk)|(esl)|(esm)|(esn)|(eso)|(esq)|(ess)|(esu)|(esx)|(esy)|(etb)|(etc)|(eth)|(etn)|(eto)|(etr)|(ets)|(ett)|(etu)|(etx)|(etz)|(euq)|(eve)|(evh)|(evn)|(ewo)|(ext)|(eya)|(eyo)|(eza)|(eze)|(faa)|(fab)|(fad)|(faf)|(fag)|(fah)|(fai)|(faj)|(fak)|(fal)|(fam)|(fan)|(fap)|(far)|(fat)|(fau)|(fax)|(fay)|(faz)|(fbl)|(fcs)|(fer)|(ffi)|(ffm)|(fgr)|(fia)|(fie)|(fil)|(fip)|(fir)|(fit)|(fiu)|(fiw)|(fkk)|(fkv)|(fla)|(flh)|(fli)|(fll)|(fln)|(flr)|(fly)|(fmp)|(fmu)|(fnb)|(fng)|(fni)|(fod)|(foi)|(fom)|(fon)|(for)|(fos)|(fox)|(fpe)|(fqs)|(frc)|(frd)|(frk)|(frm)|(fro)|(frp)|(frq)|(frr)|(frs)|(frt)|(fse)|(fsl)|(fss)|(fub)|(fuc)|(fud)|(fue)|(fuf)|(fuh)|(fui)|(fuj)|(fum)|(fun)|(fuq)|(fur)|(fut)|(fuu)|(fuv)|(fuy)|(fvr)|(fwa)|(fwe)|(gaa)|(gab)|(gac)|(gad)|(gae)|(gaf)|(gag)|(gah)|(gai)|(gaj)|(gak)|(gal)|(gam)|(gan)|(gao)|(gap)|(gaq)|(gar)|(gas)|(gat)|(gau)|(gav)|(gaw)|(gax)|(gay)|(gaz)|(gba)|(gbb)|(gbc)|(gbd)|(gbe)|(gbf)|(gbg)|(gbh)|(gbi)|(gbj)|(gbk)|(gbl)|(gbm)|(gbn)|(gbo)|(gbp)|(gbq)|(gbr)|(gbs)|(gbu)|(gbv)|(gbw)|(gbx)|(gby)|(gbz)|(gcc)|(gcd)|(gce)|(gcf)|(gcl)|(gcn)|(gcr)|(gct)|(gda)|(gdb)|(gdc)|(gdd)|(gde)|(gdf)|(gdg)|(gdh)|(gdi)|(gdj)|(gdk)|(gdl)|(gdm)|(gdn)|(gdo)|(gdq)|(gdr)|(gds)|(gdt)|(gdu)|(gdx)|(gea)|(geb)|(gec)|(ged)|(geg)|(geh)|(gei)|(gej)|(gek)|(gel)|(gem)|(geq)|(ges)|(gev)|(gew)|(gex)|(gey)|(gez)|(gfk)|(gft)|(gfx)|(gga)|(ggb)|(ggd)|(gge)|(ggg)|(ggk)|(ggl)|(ggn)|(ggo)|(ggr)|(ggt)|(ggu)|(ggw)|(gha)|(ghc)|(ghe)|(ghh)|(ghk)|(ghl)|(ghn)|(gho)|(ghr)|(ghs)|(ght)|(gia)|(gib)|(gic)|(gid)|(gie)|(gig)|(gih)|(gil)|(gim)|(gin)|(gio)|(gip)|(giq)|(gir)|(gis)|(git)|(giu)|(giw)|(gix)|(giy)|(giz)|(gji)|(gjk)|(gjm)|(gjn)|(gjr)|(gju)|(gka)|(gke)|(gkn)|(gko)|(gkp)|(gku)|(glc)|(gld)|(glh)|(gli)|(glj)|(glk)|(gll)|(glo)|(glr)|(glu)|(glw)|(gly)|(gma)|(gmb)|(gmd)|(gme)|(gmg)|(gmh)|(gml)|(gmm)|(gmn)|(gmq)|(gmu)|(gmv)|(gmw)|(gmx)|(gmy)|(gmz)|(gna)|(gnb)|(gnc)|(gnd)|(gne)|(gng)|(gnh)|(gni)|(gnk)|(gnl)|(gnm)|(gnn)|(gno)|(gnq)|(gnr)|(gnt)|(gnu)|(gnw)|(gnz)|(goa)|(gob)|(goc)|(god)|(goe)|(gof)|(gog)|(goh)|(goi)|(goj)|(gok)|(gol)|(gom)|(gon)|(goo)|(gop)|(goq)|(gor)|(gos)|(got)|(gou)|(gow)|(gox)|(goy)|(goz)|(gpa)|(gpe)|(gpn)|(gqa)|(gqi)|(gqn)|(gqr)|(gqu)|(gra)|(grb)|(grc)|(grd)|(grg)|(grh)|(gri)|(grj)|(grk)|(grm)|(gro)|(grq)|(grr)|(grs)|(grt)|(gru)|(grv)|(grw)|(grx)|(gry)|(grz)|(gse)|(gsg)|(gsl)|(gsm)|(gsn)|(gso)|(gsp)|(gss)|(gsw)|(gta)|(gti)|(gtu)|(gua)|(gub)|(guc)|(gud)|(gue)|(guf)|(gug)|(guh)|(gui)|(guk)|(gul)|(gum)|(gun)|(guo)|(gup)|(guq)|(gur)|(gus)|(gut)|(guu)|(guv)|(guw)|(gux)|(guz)|(gva)|(gvc)|(gve)|(gvf)|(gvj)|(gvl)|(gvm)|(gvn)|(gvo)|(gvp)|(gvr)|(gvs)|(gvy)|(gwa)|(gwb)|(gwc)|(gwd)|(gwe)|(gwf)|(gwg)|(gwi)|(gwj)|(gwm)|(gwn)|(gwr)|(gwt)|(gwu)|(gww)|(gwx)|(gxx)|(gya)|(gyb)|(gyd)|(gye)|(gyf)|(gyg)|(gyi)|(gyl)|(gym)|(gyn)|(gyr)|(gyy)|(gza)|(gzi)|(gzn)|(haa)|(hab)|(hac)|(had)|(hae)|(haf)|(hag)|(hah)|(hai)|(haj)|(hak)|(hal)|(ham)|(han)|(hao)|(hap)|(haq)|(har)|(has)|(hav)|(haw)|(hax)|(hay)|(haz)|(hba)|(hbb)|(hbn)|(hbo)|(hbu)|(hca)|(hch)|(hdn)|(hds)|(hdy)|(hea)|(hed)|(heg)|(heh)|(hei)|(hem)|(hgm)|(hgw)|(hhi)|(hhr)|(hhy)|(hia)|(hib)|(hid)|(hif)|(hig)|(hih)|(hii)|(hij)|(hik)|(hil)|(him)|(hio)|(hir)|(hit)|(hiw)|(hix)|(hji)|(hka)|(hke)|(hkk)|(hks)|(hla)|(hlb)|(hld)|(hle)|(hlt)|(hlu)|(hma)|(hmb)|(hmc)|(hmd)|(hme)|(hmf)|(hmg)|(hmh)|(hmi)|(hmj)|(hmk)|(hml)|(hmm)|(hmn)|(hmp)|(hmq)|(hmr)|(hms)|(hmt)|(hmu)|(hmv)|(hmw)|(hmx)|(hmy)|(hmz)|(hna)|(hnd)|(hne)|(hnh)|(hni)|(hnj)|(hnn)|(hno)|(hns)|(hnu)|(hoa)|(hob)|(hoc)|(hod)|(hoe)|(hoh)|(hoi)|(hoj)|(hok)|(hol)|(hom)|(hoo)|(hop)|(hor)|(hos)|(hot)|(hov)|(how)|(hoy)|(hoz)|(hpo)|(hps)|(hra)|(hrc)|(hre)|(hrk)|(hrm)|(hro)|(hrp)|(hrr)|(hrt)|(hru)|(hrw)|(hrx)|(hrz)|(hsb)|(hsh)|(hsl)|(hsn)|(hss)|(hti)|(hto)|(hts)|(htu)|(htx)|(hub)|(huc)|(hud)|(hue)|(huf)|(hug)|(huh)|(hui)|(huj)|(huk)|(hul)|(hum)|(huo)|(hup)|(huq)|(hur)|(hus)|(hut)|(huu)|(huv)|(huw)|(hux)|(huy)|(huz)|(hvc)|(hve)|(hvk)|(hvn)|(hvv)|(hwa)|(hwc)|(hwo)|(hya)|(hyx)|(iai)|(ian)|(iap)|(iar)|(iba)|(ibb)|(ibd)|(ibe)|(ibg)|(ibh)|(ibi)|(ibl)|(ibm)|(ibn)|(ibr)|(ibu)|(iby)|(ica)|(ich)|(icl)|(icr)|(ida)|(idb)|(idc)|(idd)|(ide)|(idi)|(idr)|(ids)|(idt)|(idu)|(ifa)|(ifb)|(ife)|(iff)|(ifk)|(ifm)|(ifu)|(ify)|(igb)|(ige)|(igg)|(igl)|(igm)|(ign)|(igo)|(igs)|(igw)|(ihb)|(ihi)|(ihp)|(ihw)|(iin)|(iir)|(ijc)|(ije)|(ijj)|(ijn)|(ijo)|(ijs)|(ike)|(iki)|(ikk)|(ikl)|(iko)|(ikp)|(ikr)|(iks)|(ikt)|(ikv)|(ikw)|(ikx)|(ikz)|(ila)|(ilb)|(ilg)|(ili)|(ilk)|(ill)|(ilm)|(ilo)|(ilp)|(ils)|(ilu)|(ilv)|(ilw)|(ima)|(ime)|(imi)|(iml)|(imn)|(imo)|(imr)|(ims)|(imy)|(inb)|(inc)|(ine)|(ing)|(inh)|(inj)|(inl)|(inm)|(inn)|(ino)|(inp)|(ins)|(int)|(inz)|(ior)|(iou)|(iow)|(ipi)|(ipo)|(iqu)|(iqw)|(ira)|(ire)|(irh)|(iri)|(irk)|(irn)|(iro)|(irr)|(iru)|(irx)|(iry)|(isa)|(isc)|(isd)|(ise)|(isg)|(ish)|(isi)|(isk)|(ism)|(isn)|(iso)|(isr)|(ist)|(isu)|(itb)|(itc)|(itd)|(ite)|(iti)|(itk)|(itl)|(itm)|(ito)|(itr)|(its)|(itt)|(itv)|(itw)|(itx)|(ity)|(itz)|(ium)|(ivb)|(ivv)|(iwk)|(iwm)|(iwo)|(iws)|(ixc)|(ixl)|(iya)|(iyo)|(iyx)|(izh)|(izi)|(izr)|(izz)|(jaa)|(jab)|(jac)|(jad)|(jae)|(jaf)|(jah)|(jaj)|(jak)|(jal)|(jam)|(jan)|(jao)|(jaq)|(jar)|(jas)|(jat)|(jau)|(jax)|(jay)|(jaz)|(jbe)|(jbi)|(jbj)|(jbk)|(jbn)|(jbo)|(jbr)|(jbt)|(jbu)|(jbw)|(jcs)|(jct)|(jda)|(jdg)|(jdt)|(jeb)|(jee)|(jeg)|(jeh)|(jei)|(jek)|(jel)|(jen)|(jer)|(jet)|(jeu)|(jgb)|(jge)|(jgk)|(jgo)|(jhi)|(jhs)|(jia)|(jib)|(jic)|(jid)|(jie)|(jig)|(jih)|(jii)|(jil)|(jim)|(jio)|(jiq)|(jit)|(jiu)|(jiv)|(jiy)|(jje)|(jjr)|(jka)|(jkm)|(jko)|(jkp)|(jkr)|(jku)|(jle)|(jls)|(jma)|(jmb)|(jmc)|(jmd)|(jmi)|(jml)|(jmn)|(jmr)|(jms)|(jmw)|(jmx)|(jna)|(jnd)|(jng)|(jni)|(jnj)|(jnl)|(jns)|(job)|(jod)|(jog)|(jor)|(jos)|(jow)|(jpa)|(jpr)|(jpx)|(jqr)|(jra)|(jrb)|(jrr)|(jrt)|(jru)|(jsl)|(jua)|(jub)|(juc)|(jud)|(juh)|(jui)|(juk)|(jul)|(jum)|(jun)|(juo)|(jup)|(jur)|(jus)|(jut)|(juu)|(juw)|(juy)|(jvd)|(jvn)|(jwi)|(jya)|(jye)|(jyy)|(kaa)|(kab)|(kac)|(kad)|(kae)|(kaf)|(kag)|(kah)|(kai)|(kaj)|(kak)|(kam)|(kao)|(kap)|(kaq)|(kar)|(kav)|(kaw)|(kax)|(kay)|(kba)|(kbb)|(kbc)|(kbd)|(kbe)|(kbf)|(kbg)|(kbh)|(kbi)|(kbj)|(kbk)|(kbl)|(kbm)|(kbn)|(kbo)|(kbp)|(kbq)|(kbr)|(kbs)|(kbt)|(kbu)|(kbv)|(kbw)|(kbx)|(kby)|(kbz)|(kca)|(kcb)|(kcc)|(kcd)|(kce)|(kcf)|(kcg)|(kch)|(kci)|(kcj)|(kck)|(kcl)|(kcm)|(kcn)|(kco)|(kcp)|(kcq)|(kcr)|(kcs)|(kct)|(kcu)|(kcv)|(kcw)|(kcx)|(kcy)|(kcz)|(kda)|(kdc)|(kdd)|(kde)|(kdf)|(kdg)|(kdh)|(kdi)|(kdj)|(kdk)|(kdl)|(kdm)|(kdn)|(kdo)|(kdp)|(kdq)|(kdr)|(kdt)|(kdu)|(kdv)|(kdw)|(kdx)|(kdy)|(kdz)|(kea)|(keb)|(kec)|(ked)|(kee)|(kef)|(keg)|(keh)|(kei)|(kej)|(kek)|(kel)|(kem)|(ken)|(keo)|(kep)|(keq)|(ker)|(kes)|(ket)|(keu)|(kev)|(kew)|(kex)|(key)|(kez)|(kfa)|(kfb)|(kfc)|(kfd)|(kfe)|(kff)|(kfg)|(kfh)|(kfi)|(kfj)|(kfk)|(kfl)|(kfm)|(kfn)|(kfo)|(kfp)|(kfq)|(kfr)|(kfs)|(kft)|(kfu)|(kfv)|(kfw)|(kfx)|(kfy)|(kfz)|(kga)|(kgb)|(kgc)|(kgd)|(kge)|(kgf)|(kgg)|(kgh)|(kgi)|(kgj)|(kgk)|(kgl)|(kgm)|(kgn)|(kgo)|(kgp)|(kgq)|(kgr)|(kgs)|(kgt)|(kgu)|(kgv)|(kgw)|(kgx)|(kgy)|(kha)|(khb)|(khc)|(khd)|(khe)|(khf)|(khg)|(khh)|(khi)|(khj)|(khk)|(khl)|(khn)|(kho)|(khp)|(khq)|(khr)|(khs)|(kht)|(khu)|(khv)|(khw)|(khx)|(khy)|(khz)|(kia)|(kib)|(kic)|(kid)|(kie)|(kif)|(kig)|(kih)|(kii)|(kij)|(kil)|(kim)|(kio)|(kip)|(kiq)|(kis)|(kit)|(kiu)|(kiv)|(kiw)|(kix)|(kiy)|(kiz)|(kja)|(kjb)|(kjc)|(kjd)|(kje)|(kjf)|(kjg)|(kjh)|(kji)|(kjj)|(kjk)|(kjl)|(kjm)|(kjn)|(kjo)|(kjp)|(kjq)|(kjr)|(kjs)|(kjt)|(kju)|(kjv)|(kjx)|(kjy)|(kjz)|(kka)|(kkb)|(kkc)|(kkd)|(kke)|(kkf)|(kkg)|(kkh)|(kki)|(kkj)|(kkk)|(kkl)|(kkm)|(kkn)|(kko)|(kkp)|(kkq)|(kkr)|(kks)|(kkt)|(kku)|(kkv)|(kkw)|(kkx)|(kky)|(kkz)|(kla)|(klb)|(klc)|(kld)|(kle)|(klf)|(klg)|(klh)|(kli)|(klj)|(klk)|(kll)|(klm)|(kln)|(klo)|(klp)|(klq)|(klr)|(kls)|(klt)|(klu)|(klv)|(klw)|(klx)|(kly)|(klz)|(kma)|(kmb)|(kmc)|(kmd)|(kme)|(kmf)|(kmg)|(kmh)|(kmi)|(kmj)|(kmk)|(kml)|(kmm)|(kmn)|(kmo)|(kmp)|(kmq)|(kmr)|(kms)|(kmt)|(kmu)|(kmv)|(kmw)|(kmx)|(kmy)|(kmz)|(kna)|(knb)|(knc)|(knd)|(kne)|(knf)|(kng)|(kni)|(knj)|(knk)|(knl)|(knm)|(knn)|(kno)|(knp)|(knq)|(knr)|(kns)|(knt)|(knu)|(knv)|(knw)|(knx)|(kny)|(knz)|(koa)|(koc)|(kod)|(koe)|(kof)|(kog)|(koh)|(koi)|(koj)|(kok)|(kol)|(koo)|(kop)|(koq)|(kos)|(kot)|(kou)|(kov)|(kow)|(kox)|(koy)|(koz)|(kpa)|(kpb)|(kpc)|(kpd)|(kpe)|(kpf)|(kpg)|(kph)|(kpi)|(kpj)|(kpk)|(kpl)|(kpm)|(kpn)|(kpo)|(kpp)|(kpq)|(kpr)|(kps)|(kpt)|(kpu)|(kpv)|(kpw)|(kpx)|(kpy)|(kpz)|(kqa)|(kqb)|(kqc)|(kqd)|(kqe)|(kqf)|(kqg)|(kqh)|(kqi)|(kqj)|(kqk)|(kql)|(kqm)|(kqn)|(kqo)|(kqp)|(kqq)|(kqr)|(kqs)|(kqt)|(kqu)|(kqv)|(kqw)|(kqx)|(kqy)|(kqz)|(kra)|(krb)|(krc)|(krd)|(kre)|(krf)|(krh)|(kri)|(krj)|(krk)|(krl)|(krm)|(krn)|(kro)|(krp)|(krr)|(krs)|(krt)|(kru)|(krv)|(krw)|(krx)|(kry)|(krz)|(ksa)|(ksb)|(ksc)|(ksd)|(kse)|(ksf)|(ksg)|(ksh)|(ksi)|(ksj)|(ksk)|(ksl)|(ksm)|(ksn)|(kso)|(ksp)|(ksq)|(ksr)|(kss)|(kst)|(ksu)|(ksv)|(ksw)|(ksx)|(ksy)|(ksz)|(kta)|(ktb)|(ktc)|(ktd)|(kte)|(ktf)|(ktg)|(kth)|(kti)|(ktj)|(ktk)|(ktl)|(ktm)|(ktn)|(kto)|(ktp)|(ktq)|(ktr)|(kts)|(ktt)|(ktu)|(ktv)|(ktw)|(ktx)|(kty)|(ktz)|(kub)|(kuc)|(kud)|(kue)|(kuf)|(kug)|(kuh)|(kui)|(kuj)|(kuk)|(kul)|(kum)|(kun)|(kuo)|(kup)|(kuq)|(kus)|(kut)|(kuu)|(kuv)|(kuw)|(kux)|(kuy)|(kuz)|(kva)|(kvb)|(kvc)|(kvd)|(kve)|(kvf)|(kvg)|(kvh)|(kvi)|(kvj)|(kvk)|(kvl)|(kvm)|(kvn)|(kvo)|(kvp)|(kvq)|(kvr)|(kvs)|(kvt)|(kvu)|(kvv)|(kvw)|(kvx)|(kvy)|(kvz)|(kwa)|(kwb)|(kwc)|(kwd)|(kwe)|(kwf)|(kwg)|(kwh)|(kwi)|(kwj)|(kwk)|(kwl)|(kwm)|(kwn)|(kwo)|(kwp)|(kwq)|(kwr)|(kws)|(kwt)|(kwu)|(kwv)|(kww)|(kwx)|(kwy)|(kwz)|(kxa)|(kxb)|(kxc)|(kxd)|(kxe)|(kxf)|(kxh)|(kxi)|(kxj)|(kxk)|(kxl)|(kxm)|(kxn)|(kxo)|(kxp)|(kxq)|(kxr)|(kxs)|(kxt)|(kxu)|(kxv)|(kxw)|(kxx)|(kxy)|(kxz)|(kya)|(kyb)|(kyc)|(kyd)|(kye)|(kyf)|(kyg)|(kyh)|(kyi)|(kyj)|(kyk)|(kyl)|(kym)|(kyn)|(kyo)|(kyp)|(kyq)|(kyr)|(kys)|(kyt)|(kyu)|(kyv)|(kyw)|(kyx)|(kyy)|(kyz)|(kza)|(kzb)|(kzc)|(kzd)|(kze)|(kzf)|(kzg)|(kzh)|(kzi)|(kzj)|(kzk)|(kzl)|(kzm)|(kzn)|(kzo)|(kzp)|(kzq)|(kzr)|(kzs)|(kzt)|(kzu)|(kzv)|(kzw)|(kzx)|(kzy)|(kzz)|(laa)|(lab)|(lac)|(lad)|(lae)|(laf)|(lag)|(lah)|(lai)|(laj)|(lak)|(lal)|(lam)|(lan)|(lap)|(laq)|(lar)|(las)|(lau)|(law)|(lax)|(lay)|(laz)|(lba)|(lbb)|(lbc)|(lbe)|(lbf)|(lbg)|(lbi)|(lbj)|(lbk)|(lbl)|(lbm)|(lbn)|(lbo)|(lbq)|(lbr)|(lbs)|(lbt)|(lbu)|(lbv)|(lbw)|(lbx)|(lby)|(lbz)|(lcc)|(lcd)|(lce)|(lcf)|(lch)|(lcl)|(lcm)|(lcp)|(lcq)|(lcs)|(lda)|(ldb)|(ldd)|(ldg)|(ldh)|(ldi)|(ldj)|(ldk)|(ldl)|(ldm)|(ldn)|(ldo)|(ldp)|(ldq)|(lea)|(leb)|(lec)|(led)|(lee)|(lef)|(leg)|(leh)|(lei)|(lej)|(lek)|(lel)|(lem)|(len)|(leo)|(lep)|(leq)|(ler)|(les)|(let)|(leu)|(lev)|(lew)|(lex)|(ley)|(lez)|(lfa)|(lfn)|(lga)|(lgb)|(lgg)|(lgh)|(lgi)|(lgk)|(lgl)|(lgm)|(lgn)|(lgq)|(lgr)|(lgt)|(lgu)|(lgz)|(lha)|(lhh)|(lhi)|(lhl)|(lhm)|(lhn)|(lhp)|(lhs)|(lht)|(lhu)|(lia)|(lib)|(lic)|(lid)|(lie)|(lif)|(lig)|(lih)|(lii)|(lij)|(lik)|(lil)|(lio)|(lip)|(liq)|(lir)|(lis)|(liu)|(liv)|(liw)|(lix)|(liy)|(liz)|(lja)|(lje)|(lji)|(ljl)|(ljp)|(ljw)|(ljx)|(lka)|(lkb)|(lkc)|(lkd)|(lke)|(lkh)|(lki)|(lkj)|(lkl)|(lkm)|(lkn)|(lko)|(lkr)|(lks)|(lkt)|(lku)|(lky)|(lla)|(llb)|(llc)|(lld)|(lle)|(llf)|(llg)|(llh)|(lli)|(llj)|(llk)|(lll)|(llm)|(lln)|(llo)|(llp)|(llq)|(lls)|(llu)|(llx)|(lma)|(lmb)|(lmc)|(lmd)|(lme)|(lmf)|(lmg)|(lmh)|(lmi)|(lmj)|(lmk)|(lml)|(lmm)|(lmn)|(lmo)|(lmp)|(lmq)|(lmr)|(lmu)|(lmv)|(lmw)|(lmx)|(lmy)|(lmz)|(lna)|(lnb)|(lnd)|(lng)|(lnh)|(lni)|(lnj)|(lnl)|(lnm)|(lnn)|(lno)|(lns)|(lnu)|(lnw)|(lnz)|(loa)|(lob)|(loc)|(loe)|(lof)|(log)|(loh)|(loi)|(loj)|(lok)|(lol)|(lom)|(lon)|(loo)|(lop)|(loq)|(lor)|(los)|(lot)|(lou)|(lov)|(low)|(lox)|(loy)|(loz)|(lpa)|(lpe)|(lpn)|(lpo)|(lpx)|(lra)|(lrc)|(lre)|(lrg)|(lri)|(lrk)|(lrl)|(lrm)|(lrn)|(lro)|(lrr)|(lrt)|(lrv)|(lrz)|(lsa)|(lsd)|(lse)|(lsg)|(lsh)|(lsi)|(lsl)|(lsm)|(lso)|(lsp)|(lsr)|(lss)|(lst)|(lsy)|(ltc)|(ltg)|(lth)|(lti)|(ltn)|(lto)|(lts)|(ltu)|(lua)|(luc)|(lud)|(lue)|(luf)|(lui)|(luj)|(luk)|(lul)|(lum)|(lun)|(luo)|(lup)|(luq)|(lur)|(lus)|(lut)|(luu)|(luv)|(luw)|(luy)|(luz)|(lva)|(lvk)|(lvs)|(lvu)|(lwa)|(lwe)|(lwg)|(lwh)|(lwl)|(lwm)|(lwo)|(lwt)|(lwu)|(lww)|(lya)|(lyg)|(lyn)|(lzh)|(lzl)|(lzn)|(lzz)|(maa)|(mab)|(mad)|(mae)|(maf)|(mag)|(mai)|(maj)|(mak)|(mam)|(man)|(map)|(maq)|(mas)|(mat)|(mau)|(mav)|(maw)|(max)|(maz)|(mba)|(mbb)|(mbc)|(mbd)|(mbe)|(mbf)|(mbh)|(mbi)|(mbj)|(mbk)|(mbl)|(mbm)|(mbn)|(mbo)|(mbp)|(mbq)|(mbr)|(mbs)|(mbt)|(mbu)|(mbv)|(mbw)|(mbx)|(mby)|(mbz)|(mca)|(mcb)|(mcc)|(mcd)|(mce)|(mcf)|(mcg)|(mch)|(mci)|(mcj)|(mck)|(mcl)|(mcm)|(mcn)|(mco)|(mcp)|(mcq)|(mcr)|(mcs)|(mct)|(mcu)|(mcv)|(mcw)|(mcx)|(mcy)|(mcz)|(mda)|(mdb)|(mdc)|(mdd)|(mde)|(mdf)|(mdg)|(mdh)|(mdi)|(mdj)|(mdk)|(mdl)|(mdm)|(mdn)|(mdp)|(mdq)|(mdr)|(mds)|(mdt)|(mdu)|(mdv)|(mdw)|(mdx)|(mdy)|(mdz)|(mea)|(meb)|(mec)|(med)|(mee)|(mef)|(meg)|(meh)|(mei)|(mej)|(mek)|(mel)|(mem)|(men)|(meo)|(mep)|(meq)|(mer)|(mes)|(met)|(meu)|(mev)|(mew)|(mey)|(mez)|(mfa)|(mfb)|(mfc)|(mfd)|(mfe)|(mff)|(mfg)|(mfh)|(mfi)|(mfj)|(mfk)|(mfl)|(mfm)|(mfn)|(mfo)|(mfp)|(mfq)|(mfr)|(mfs)|(mft)|(mfu)|(mfv)|(mfw)|(mfx)|(mfy)|(mfz)|(mga)|(mgb)|(mgc)|(mgd)|(mge)|(mgf)|(mgg)|(mgh)|(mgi)|(mgj)|(mgk)|(mgl)|(mgm)|(mgn)|(mgo)|(mgp)|(mgq)|(mgr)|(mgs)|(mgt)|(mgu)|(mgv)|(mgw)|(mgx)|(mgy)|(mgz)|(mha)|(mhb)|(mhc)|(mhd)|(mhe)|(mhf)|(mhg)|(mhh)|(mhi)|(mhj)|(mhk)|(mhl)|(mhm)|(mhn)|(mho)|(mhp)|(mhq)|(mhr)|(mhs)|(mht)|(mhu)|(mhw)|(mhx)|(mhy)|(mhz)|(mia)|(mib)|(mic)|(mid)|(mie)|(mif)|(mig)|(mih)|(mii)|(mij)|(mik)|(mil)|(mim)|(min)|(mio)|(mip)|(miq)|(mir)|(mis)|(mit)|(miu)|(miw)|(mix)|(miy)|(miz)|(mja)|(mjb)|(mjc)|(mjd)|(mje)|(mjg)|(mjh)|(mji)|(mjj)|(mjk)|(mjl)|(mjm)|(mjn)|(mjo)|(mjp)|(mjq)|(mjr)|(mjs)|(mjt)|(mju)|(mjv)|(mjw)|(mjx)|(mjy)|(mjz)|(mka)|(mkb)|(mkc)|(mke)|(mkf)|(mkg)|(mkh)|(mki)|(mkj)|(mkk)|(mkl)|(mkm)|(mkn)|(mko)|(mkp)|(mkq)|(mkr)|(mks)|(mkt)|(mku)|(mkv)|(mkw)|(mkx)|(mky)|(mkz)|(mla)|(mlb)|(mlc)|(mld)|(mle)|(mlf)|(mlh)|(mli)|(mlj)|(mlk)|(mll)|(mlm)|(mln)|(mlo)|(mlp)|(mlq)|(mlr)|(mls)|(mlu)|(mlv)|(mlw)|(mlx)|(mlz)|(mma)|(mmb)|(mmc)|(mmd)|(mme)|(mmf)|(mmg)|(mmh)|(mmi)|(mmj)|(mmk)|(mml)|(mmm)|(mmn)|(mmo)|(mmp)|(mmq)|(mmr)|(mmt)|(mmu)|(mmv)|(mmw)|(mmx)|(mmy)|(mmz)|(mna)|(mnb)|(mnc)|(mnd)|(mne)|(mnf)|(mng)|(mnh)|(mni)|(mnj)|(mnk)|(mnl)|(mnm)|(mnn)|(mno)|(mnp)|(mnq)|(mnr)|(mns)|(mnt)|(mnu)|(mnv)|(mnw)|(mnx)|(mny)|(mnz)|(moa)|(moc)|(mod)|(moe)|(mof)|(mog)|(moh)|(moi)|(moj)|(mok)|(mom)|(moo)|(mop)|(moq)|(mor)|(mos)|(mot)|(mou)|(mov)|(mow)|(mox)|(moy)|(moz)|(mpa)|(mpb)|(mpc)|(mpd)|(mpe)|(mpg)|(mph)|(mpi)|(mpj)|(mpk)|(mpl)|(mpm)|(mpn)|(mpo)|(mpp)|(mpq)|(mpr)|(mps)|(mpt)|(mpu)|(mpv)|(mpw)|(mpx)|(mpy)|(mpz)|(mqa)|(mqb)|(mqc)|(mqe)|(mqf)|(mqg)|(mqh)|(mqi)|(mqj)|(mqk)|(mql)|(mqm)|(mqn)|(mqo)|(mqp)|(mqq)|(mqr)|(mqs)|(mqt)|(mqu)|(mqv)|(mqw)|(mqx)|(mqy)|(mqz)|(mra)|(mrb)|(mrc)|(mrd)|(mre)|(mrf)|(mrg)|(mrh)|(mrj)|(mrk)|(mrl)|(mrm)|(mrn)|(mro)|(mrp)|(mrq)|(mrr)|(mrs)|(mrt)|(mru)|(mrv)|(mrw)|(mrx)|(mry)|(mrz)|(msb)|(msc)|(msd)|(mse)|(msf)|(msg)|(msh)|(msi)|(msj)|(msk)|(msl)|(msm)|(msn)|(mso)|(msp)|(msq)|(msr)|(mss)|(mst)|(msu)|(msv)|(msw)|(msx)|(msy)|(msz)|(mta)|(mtb)|(mtc)|(mtd)|(mte)|(mtf)|(mtg)|(mth)|(mti)|(mtj)|(mtk)|(mtl)|(mtm)|(mtn)|(mto)|(mtp)|(mtq)|(mtr)|(mts)|(mtt)|(mtu)|(mtv)|(mtw)|(mtx)|(mty)|(mua)|(mub)|(muc)|(mud)|(mue)|(mug)|(muh)|(mui)|(muj)|(muk)|(mul)|(mum)|(mun)|(muo)|(mup)|(muq)|(mur)|(mus)|(mut)|(muu)|(muv)|(mux)|(muy)|(muz)|(mva)|(mvb)|(mvd)|(mve)|(mvf)|(mvg)|(mvh)|(mvi)|(mvk)|(mvl)|(mvm)|(mvn)|(mvo)|(mvp)|(mvq)|(mvr)|(mvs)|(mvt)|(mvu)|(mvv)|(mvw)|(mvx)|(mvy)|(mvz)|(mwa)|(mwb)|(mwc)|(mwd)|(mwe)|(mwf)|(mwg)|(mwh)|(mwi)|(mwj)|(mwk)|(mwl)|(mwm)|(mwn)|(mwo)|(mwp)|(mwq)|(mwr)|(mws)|(mwt)|(mwu)|(mwv)|(mww)|(mwx)|(mwy)|(mwz)|(mxa)|(mxb)|(mxc)|(mxd)|(mxe)|(mxf)|(mxg)|(mxh)|(mxi)|(mxj)|(mxk)|(mxl)|(mxm)|(mxn)|(mxo)|(mxp)|(mxq)|(mxr)|(mxs)|(mxt)|(mxu)|(mxv)|(mxw)|(mxx)|(mxy)|(mxz)|(myb)|(myc)|(myd)|(mye)|(myf)|(myg)|(myh)|(myi)|(myj)|(myk)|(myl)|(mym)|(myn)|(myo)|(myp)|(myq)|(myr)|(mys)|(myt)|(myu)|(myv)|(myw)|(myx)|(myy)|(myz)|(mza)|(mzb)|(mzc)|(mzd)|(mze)|(mzg)|(mzh)|(mzi)|(mzj)|(mzk)|(mzl)|(mzm)|(mzn)|(mzo)|(mzp)|(mzq)|(mzr)|(mzs)|(mzt)|(mzu)|(mzv)|(mzw)|(mzx)|(mzy)|(mzz)|(naa)|(nab)|(nac)|(nad)|(nae)|(naf)|(nag)|(nah)|(nai)|(naj)|(nak)|(nal)|(nam)|(nan)|(nao)|(nap)|(naq)|(nar)|(nas)|(nat)|(naw)|(nax)|(nay)|(naz)|(nba)|(nbb)|(nbc)|(nbd)|(nbe)|(nbf)|(nbg)|(nbh)|(nbi)|(nbj)|(nbk)|(nbm)|(nbn)|(nbo)|(nbp)|(nbq)|(nbr)|(nbs)|(nbt)|(nbu)|(nbv)|(nbw)|(nbx)|(nby)|(nca)|(ncb)|(ncc)|(ncd)|(nce)|(ncf)|(ncg)|(nch)|(nci)|(ncj)|(nck)|(ncl)|(ncm)|(ncn)|(nco)|(ncp)|(ncq)|(ncr)|(ncs)|(nct)|(ncu)|(ncx)|(ncz)|(nda)|(ndb)|(ndc)|(ndd)|(ndf)|(ndg)|(ndh)|(ndi)|(ndj)|(ndk)|(ndl)|(ndm)|(ndn)|(ndp)|(ndq)|(ndr)|(nds)|(ndt)|(ndu)|(ndv)|(ndw)|(ndx)|(ndy)|(ndz)|(nea)|(neb)|(nec)|(ned)|(nee)|(nef)|(neg)|(neh)|(nei)|(nej)|(nek)|(nem)|(nen)|(neo)|(neq)|(ner)|(nes)|(net)|(neu)|(nev)|(new)|(nex)|(ney)|(nez)|(nfa)|(nfd)|(nfl)|(nfr)|(nfu)|(nga)|(ngb)|(ngc)|(ngd)|(nge)|(ngf)|(ngg)|(ngh)|(ngi)|(ngj)|(ngk)|(ngl)|(ngm)|(ngn)|(ngo)|(ngp)|(ngq)|(ngr)|(ngs)|(ngt)|(ngu)|(ngv)|(ngw)|(ngx)|(ngy)|(ngz)|(nha)|(nhb)|(nhc)|(nhd)|(nhe)|(nhf)|(nhg)|(nhh)|(nhi)|(nhk)|(nhm)|(nhn)|(nho)|(nhp)|(nhq)|(nhr)|(nht)|(nhu)|(nhv)|(nhw)|(nhx)|(nhy)|(nhz)|(nia)|(nib)|(nic)|(nid)|(nie)|(nif)|(nig)|(nih)|(nii)|(nij)|(nik)|(nil)|(nim)|(nin)|(nio)|(niq)|(nir)|(nis)|(nit)|(niu)|(niv)|(niw)|(nix)|(niy)|(niz)|(nja)|(njb)|(njd)|(njh)|(nji)|(njj)|(njl)|(njm)|(njn)|(njo)|(njr)|(njs)|(njt)|(nju)|(njx)|(njy)|(njz)|(nka)|(nkb)|(nkc)|(nkd)|(nke)|(nkf)|(nkg)|(nkh)|(nki)|(nkj)|(nkk)|(nkm)|(nkn)|(nko)|(nkp)|(nkq)|(nkr)|(nks)|(nkt)|(nku)|(nkv)|(nkw)|(nkx)|(nkz)|(nla)|(nlc)|(nle)|(nlg)|(nli)|(nlj)|(nlk)|(nll)|(nln)|(nlo)|(nlq)|(nlr)|(nlu)|(nlv)|(nlw)|(nlx)|(nly)|(nlz)|(nma)|(nmb)|(nmc)|(nmd)|(nme)|(nmf)|(nmg)|(nmh)|(nmi)|(nmj)|(nmk)|(nml)|(nmm)|(nmn)|(nmo)|(nmp)|(nmq)|(nmr)|(nms)|(nmt)|(nmu)|(nmv)|(nmw)|(nmx)|(nmy)|(nmz)|(nna)|(nnb)|(nnc)|(nnd)|(nne)|(nnf)|(nng)|(nnh)|(nni)|(nnj)|(nnk)|(nnl)|(nnm)|(nnn)|(nnp)|(nnq)|(nnr)|(nns)|(nnt)|(nnu)|(nnv)|(nnw)|(nnx)|(nny)|(nnz)|(noa)|(noc)|(nod)|(noe)|(nof)|(nog)|(noh)|(noi)|(noj)|(nok)|(nol)|(nom)|(non)|(noo)|(nop)|(noq)|(nos)|(not)|(nou)|(nov)|(now)|(noy)|(noz)|(npa)|(npb)|(npg)|(nph)|(npi)|(npl)|(npn)|(npo)|(nps)|(npu)|(npx)|(npy)|(nqg)|(nqk)|(nql)|(nqm)|(nqn)|(nqo)|(nqq)|(nqy)|(nra)|(nrb)|(nrc)|(nre)|(nrf)|(nrg)|(nri)|(nrk)|(nrl)|(nrm)|(nrn)|(nrp)|(nrr)|(nrt)|(nru)|(nrx)|(nrz)|(nsa)|(nsc)|(nsd)|(nse)|(nsf)|(nsg)|(nsh)|(nsi)|(nsk)|(nsl)|(nsm)|(nsn)|(nso)|(nsp)|(nsq)|(nsr)|(nss)|(nst)|(nsu)|(nsv)|(nsw)|(nsx)|(nsy)|(nsz)|(ntd)|(nte)|(ntg)|(nti)|(ntj)|(ntk)|(ntm)|(nto)|(ntp)|(ntr)|(nts)|(ntu)|(ntw)|(ntx)|(nty)|(ntz)|(nua)|(nub)|(nuc)|(nud)|(nue)|(nuf)|(nug)|(nuh)|(nui)|(nuj)|(nuk)|(nul)|(num)|(nun)|(nuo)|(nup)|(nuq)|(nur)|(nus)|(nut)|(nuu)|(nuv)|(nuw)|(nux)|(nuy)|(nuz)|(nvh)|(nvm)|(nvo)|(nwa)|(nwb)|(nwc)|(nwe)|(nwg)|(nwi)|(nwm)|(nwo)|(nwr)|(nwx)|(nwy)|(nxa)|(nxd)|(nxe)|(nxg)|(nxi)|(nxk)|(nxl)|(nxm)|(nxn)|(nxo)|(nxq)|(nxr)|(nxu)|(nxx)|(nyb)|(nyc)|(nyd)|(nye)|(nyf)|(nyg)|(nyh)|(nyi)|(nyj)|(nyk)|(nyl)|(nym)|(nyn)|(nyo)|(nyp)|(nyq)|(nyr)|(nys)|(nyt)|(nyu)|(nyv)|(nyw)|(nyx)|(nyy)|(nza)|(nzb)|(nzi)|(nzk)|(nzm)|(nzs)|(nzu)|(nzy)|(nzz)|(oaa)|(oac)|(oar)|(oav)|(obi)|(obk)|(obl)|(obm)|(obo)|(obr)|(obt)|(obu)|(oca)|(och)|(oco)|(ocu)|(oda)|(odk)|(odt)|(odu)|(ofo)|(ofs)|(ofu)|(ogb)|(ogc)|(oge)|(ogg)|(ogo)|(ogu)|(oht)|(ohu)|(oia)|(oin)|(ojb)|(ojc)|(ojg)|(ojp)|(ojs)|(ojv)|(ojw)|(oka)|(okb)|(okd)|(oke)|(okg)|(okh)|(oki)|(okj)|(okk)|(okl)|(okm)|(okn)|(oko)|(okr)|(oks)|(oku)|(okv)|(okx)|(ola)|(old)|(ole)|(olk)|(olm)|(olo)|(olr)|(olt)|(olu)|(oma)|(omb)|(omc)|(ome)|(omg)|(omi)|(omk)|(oml)|(omn)|(omo)|(omp)|(omq)|(omr)|(omt)|(omu)|(omv)|(omw)|(omx)|(ona)|(onb)|(one)|(ong)|(oni)|(onj)|(onk)|(onn)|(ono)|(onp)|(onr)|(ons)|(ont)|(onu)|(onw)|(onx)|(ood)|(oog)|(oon)|(oor)|(oos)|(opa)|(opk)|(opm)|(opo)|(opt)|(opy)|(ora)|(orc)|(ore)|(org)|(orh)|(orn)|(oro)|(orr)|(ors)|(ort)|(oru)|(orv)|(orw)|(orx)|(ory)|(orz)|(osa)|(osc)|(osi)|(oso)|(osp)|(ost)|(osu)|(osx)|(ota)|(otb)|(otd)|(ote)|(oti)|(otk)|(otl)|(otm)|(otn)|(oto)|(otq)|(otr)|(ots)|(ott)|(otu)|(otw)|(otx)|(oty)|(otz)|(oua)|(oub)|(oue)|(oui)|(oum)|(oun)|(ovd)|(owi)|(owl)|(oyb)|(oyd)|(oym)|(oyy)|(ozm)|(paa)|(pab)|(pac)|(pad)|(pae)|(paf)|(pag)|(pah)|(pai)|(pak)|(pal)|(pam)|(pao)|(pap)|(paq)|(par)|(pas)|(pat)|(pau)|(pav)|(paw)|(pax)|(pay)|(paz)|(pbb)|(pbc)|(pbe)|(pbf)|(pbg)|(pbh)|(pbi)|(pbl)|(pbn)|(pbo)|(pbp)|(pbr)|(pbs)|(pbt)|(pbu)|(pbv)|(pby)|(pbz)|(pca)|(pcb)|(pcc)|(pcd)|(pce)|(pcf)|(pcg)|(pch)|(pci)|(pcj)|(pck)|(pcl)|(pcm)|(pcn)|(pcp)|(pcr)|(pcw)|(pda)|(pdc)|(pdi)|(pdn)|(pdo)|(pdt)|(pdu)|(pea)|(peb)|(ped)|(pee)|(pef)|(peg)|(peh)|(pei)|(pej)|(pek)|(pel)|(pem)|(peo)|(pep)|(peq)|(pes)|(pev)|(pex)|(pey)|(pez)|(pfa)|(pfe)|(pfl)|(pga)|(pgd)|(pgg)|(pgi)|(pgk)|(pgl)|(pgn)|(pgs)|(pgu)|(pgy)|(pgz)|(pha)|(phd)|(phg)|(phh)|(phi)|(phk)|(phl)|(phm)|(phn)|(pho)|(phq)|(phr)|(pht)|(phu)|(phv)|(phw)|(pia)|(pib)|(pic)|(pid)|(pie)|(pif)|(pig)|(pih)|(pii)|(pij)|(pil)|(pim)|(pin)|(pio)|(pip)|(pir)|(pis)|(pit)|(piu)|(piv)|(piw)|(pix)|(piy)|(piz)|(pjt)|(pka)|(pkb)|(pkc)|(pkg)|(pkh)|(pkn)|(pko)|(pkp)|(pkr)|(pks)|(pkt)|(pku)|(pla)|(plb)|(plc)|(pld)|(ple)|(plf)|(plg)|(plh)|(plj)|(plk)|(pll)|(pln)|(plo)|(plp)|(plq)|(plr)|(pls)|(plt)|(plu)|(plv)|(plw)|(ply)|(plz)|(pma)|(pmb)|(pmc)|(pmd)|(pme)|(pmf)|(pmh)|(pmi)|(pmj)|(pmk)|(pml)|(pmm)|(pmn)|(pmo)|(pmq)|(pmr)|(pms)|(pmt)|(pmu)|(pmw)|(pmx)|(pmy)|(pmz)|(pna)|(pnb)|(pnc)|(pne)|(png)|(pnh)|(pni)|(pnj)|(pnk)|(pnl)|(pnm)|(pnn)|(pno)|(pnp)|(pnq)|(pnr)|(pns)|(pnt)|(pnu)|(pnv)|(pnw)|(pnx)|(pny)|(pnz)|(poc)|(pod)|(poe)|(pof)|(pog)|(poh)|(poi)|(pok)|(pom)|(pon)|(poo)|(pop)|(poq)|(pos)|(pot)|(pov)|(pow)|(pox)|(poy)|(poz)|(ppa)|(ppe)|(ppi)|(ppk)|(ppl)|(ppm)|(ppn)|(ppo)|(ppp)|(ppq)|(ppr)|(pps)|(ppt)|(ppu)|(pqa)|(pqe)|(pqm)|(pqw)|(pra)|(prb)|(prc)|(prd)|(pre)|(prf)|(prg)|(prh)|(pri)|(prk)|(prl)|(prm)|(prn)|(pro)|(prp)|(prq)|(prr)|(prs)|(prt)|(pru)|(prw)|(prx)|(pry)|(prz)|(psa)|(psc)|(psd)|(pse)|(psg)|(psh)|(psi)|(psl)|(psm)|(psn)|(pso)|(psp)|(psq)|(psr)|(pss)|(pst)|(psu)|(psw)|(psy)|(pta)|(pth)|(pti)|(ptn)|(pto)|(ptp)|(ptq)|(ptr)|(ptt)|(ptu)|(ptv)|(ptw)|(pty)|(pua)|(pub)|(puc)|(pud)|(pue)|(puf)|(pug)|(pui)|(puj)|(puk)|(pum)|(puo)|(pup)|(puq)|(pur)|(put)|(puu)|(puw)|(pux)|(puy)|(puz)|(pwa)|(pwb)|(pwg)|(pwi)|(pwm)|(pwn)|(pwo)|(pwr)|(pww)|(pxm)|(pye)|(pym)|(pyn)|(pys)|(pyu)|(pyx)|(pyy)|(pzn)|(qaa..qtz)|(qua)|(qub)|(quc)|(qud)|(quf)|(qug)|(quh)|(qui)|(quk)|(qul)|(qum)|(qun)|(qup)|(quq)|(qur)|(qus)|(quv)|(quw)|(qux)|(quy)|(quz)|(qva)|(qvc)|(qve)|(qvh)|(qvi)|(qvj)|(qvl)|(qvm)|(qvn)|(qvo)|(qvp)|(qvs)|(qvw)|(qvy)|(qvz)|(qwa)|(qwc)|(qwe)|(qwh)|(qwm)|(qws)|(qwt)|(qxa)|(qxc)|(qxh)|(qxl)|(qxn)|(qxo)|(qxp)|(qxq)|(qxr)|(qxs)|(qxt)|(qxu)|(qxw)|(qya)|(qyp)|(raa)|(rab)|(rac)|(rad)|(raf)|(rag)|(rah)|(rai)|(raj)|(rak)|(ral)|(ram)|(ran)|(rao)|(rap)|(raq)|(rar)|(ras)|(rat)|(rau)|(rav)|(raw)|(rax)|(ray)|(raz)|(rbb)|(rbk)|(rbl)|(rbp)|(rcf)|(rdb)|(rea)|(reb)|(ree)|(reg)|(rei)|(rej)|(rel)|(rem)|(ren)|(rer)|(res)|(ret)|(rey)|(rga)|(rge)|(rgk)|(rgn)|(rgr)|(rgs)|(rgu)|(rhg)|(rhp)|(ria)|(rie)|(rif)|(ril)|(rim)|(rin)|(rir)|(rit)|(riu)|(rjg)|(rji)|(rjs)|(rka)|(rkb)|(rkh)|(rki)|(rkm)|(rkt)|(rkw)|(rma)|(rmb)|(rmc)|(rmd)|(rme)|(rmf)|(rmg)|(rmh)|(rmi)|(rmk)|(rml)|(rmm)|(rmn)|(rmo)|(rmp)|(rmq)|(rmr)|(rms)|(rmt)|(rmu)|(rmv)|(rmw)|(rmx)|(rmy)|(rmz)|(rna)|(rnd)|(rng)|(rnl)|(rnn)|(rnp)|(rnr)|(rnw)|(roa)|(rob)|(roc)|(rod)|(roe)|(rof)|(rog)|(rol)|(rom)|(roo)|(rop)|(ror)|(rou)|(row)|(rpn)|(rpt)|(rri)|(rro)|(rrt)|(rsb)|(rsi)|(rsl)|(rsm)|(rtc)|(rth)|(rtm)|(rts)|(rtw)|(rub)|(ruc)|(rue)|(ruf)|(rug)|(ruh)|(rui)|(ruk)|(ruo)|(rup)|(ruq)|(rut)|(ruu)|(ruy)|(ruz)|(rwa)|(rwk)|(rwm)|(rwo)|(rwr)|(rxd)|(rxw)|(ryn)|(rys)|(ryu)|(rzh)|(saa)|(sab)|(sac)|(sad)|(sae)|(saf)|(sah)|(sai)|(saj)|(sak)|(sal)|(sam)|(sao)|(sap)|(saq)|(sar)|(sas)|(sat)|(sau)|(sav)|(saw)|(sax)|(say)|(saz)|(sba)|(sbb)|(sbc)|(sbd)|(sbe)|(sbf)|(sbg)|(sbh)|(sbi)|(sbj)|(sbk)|(sbl)|(sbm)|(sbn)|(sbo)|(sbp)|(sbq)|(sbr)|(sbs)|(sbt)|(sbu)|(sbv)|(sbw)|(sbx)|(sby)|(sbz)|(sca)|(scb)|(sce)|(scf)|(scg)|(sch)|(sci)|(sck)|(scl)|(scn)|(sco)|(scp)|(scq)|(scs)|(sct)|(scu)|(scv)|(scw)|(scx)|(sda)|(sdb)|(sdc)|(sde)|(sdf)|(sdg)|(sdh)|(sdj)|(sdk)|(sdl)|(sdm)|(sdn)|(sdo)|(sdp)|(sdr)|(sds)|(sdt)|(sdu)|(sdv)|(sdx)|(sdz)|(sea)|(seb)|(sec)|(sed)|(see)|(sef)|(seg)|(seh)|(sei)|(sej)|(sek)|(sel)|(sem)|(sen)|(seo)|(sep)|(seq)|(ser)|(ses)|(set)|(seu)|(sev)|(sew)|(sey)|(sez)|(sfb)|(sfe)|(sfm)|(sfs)|(sfw)|(sga)|(sgb)|(sgc)|(sgd)|(sge)|(sgg)|(sgh)|(sgi)|(sgj)|(sgk)|(sgl)|(sgm)|(sgn)|(sgo)|(sgp)|(sgr)|(sgs)|(sgt)|(sgu)|(sgw)|(sgx)|(sgy)|(sgz)|(sha)|(shb)|(shc)|(shd)|(she)|(shg)|(shh)|(shi)|(shj)|(shk)|(shl)|(shm)|(shn)|(sho)|(shp)|(shq)|(shr)|(shs)|(sht)|(shu)|(shv)|(shw)|(shx)|(shy)|(shz)|(sia)|(sib)|(sid)|(sie)|(sif)|(sig)|(sih)|(sii)|(sij)|(sik)|(sil)|(sim)|(sio)|(sip)|(siq)|(sir)|(sis)|(sit)|(siu)|(siv)|(siw)|(six)|(siy)|(siz)|(sja)|(sjb)|(sjd)|(sje)|(sjg)|(sjk)|(sjl)|(sjm)|(sjn)|(sjo)|(sjp)|(sjr)|(sjs)|(sjt)|(sju)|(sjw)|(ska)|(skb)|(skc)|(skd)|(ske)|(skf)|(skg)|(skh)|(ski)|(skj)|(skk)|(skm)|(skn)|(sko)|(skp)|(skq)|(skr)|(sks)|(skt)|(sku)|(skv)|(skw)|(skx)|(sky)|(skz)|(sla)|(slc)|(sld)|(sle)|(slf)|(slg)|(slh)|(sli)|(slj)|(sll)|(slm)|(sln)|(slp)|(slq)|(slr)|(sls)|(slt)|(slu)|(slw)|(slx)|(sly)|(slz)|(sma)|(smb)|(smc)|(smd)|(smf)|(smg)|(smh)|(smi)|(smj)|(smk)|(sml)|(smm)|(smn)|(smp)|(smq)|(smr)|(sms)|(smt)|(smu)|(smv)|(smw)|(smx)|(smy)|(smz)|(snb)|(snc)|(sne)|(snf)|(sng)|(snh)|(sni)|(snj)|(snk)|(snl)|(snm)|(snn)|(sno)|(snp)|(snq)|(snr)|(sns)|(snu)|(snv)|(snw)|(snx)|(sny)|(snz)|(soa)|(sob)|(soc)|(sod)|(soe)|(sog)|(soh)|(soi)|(soj)|(sok)|(sol)|(son)|(soo)|(sop)|(soq)|(sor)|(sos)|(sou)|(sov)|(sow)|(sox)|(soy)|(soz)|(spb)|(spc)|(spd)|(spe)|(spg)|(spi)|(spk)|(spl)|(spm)|(spn)|(spo)|(spp)|(spq)|(spr)|(sps)|(spt)|(spu)|(spv)|(spx)|(spy)|(sqa)|(sqh)|(sqj)|(sqk)|(sqm)|(sqn)|(sqo)|(sqq)|(sqr)|(sqs)|(sqt)|(squ)|(sra)|(srb)|(src)|(sre)|(srf)|(srg)|(srh)|(sri)|(srk)|(srl)|(srm)|(srn)|(sro)|(srq)|(srr)|(srs)|(srt)|(sru)|(srv)|(srw)|(srx)|(sry)|(srz)|(ssa)|(ssb)|(ssc)|(ssd)|(sse)|(ssf)|(ssg)|(ssh)|(ssi)|(ssj)|(ssk)|(ssl)|(ssm)|(ssn)|(sso)|(ssp)|(ssq)|(ssr)|(sss)|(sst)|(ssu)|(ssv)|(ssx)|(ssy)|(ssz)|(sta)|(stb)|(std)|(ste)|(stf)|(stg)|(sth)|(sti)|(stj)|(stk)|(stl)|(stm)|(stn)|(sto)|(stp)|(stq)|(str)|(sts)|(stt)|(stu)|(stv)|(stw)|(sty)|(sua)|(sub)|(suc)|(sue)|(sug)|(sui)|(suj)|(suk)|(sul)|(sum)|(suq)|(sur)|(sus)|(sut)|(suv)|(suw)|(sux)|(suy)|(suz)|(sva)|(svb)|(svc)|(sve)|(svk)|(svm)|(svr)|(svs)|(svx)|(swb)|(swc)|(swf)|(swg)|(swh)|(swi)|(swj)|(swk)|(swl)|(swm)|(swn)|(swo)|(swp)|(swq)|(swr)|(sws)|(swt)|(swu)|(swv)|(sww)|(swx)|(swy)|(sxb)|(sxc)|(sxe)|(sxg)|(sxk)|(sxl)|(sxm)|(sxn)|(sxo)|(sxr)|(sxs)|(sxu)|(sxw)|(sya)|(syb)|(syc)|(syd)|(syi)|(syk)|(syl)|(sym)|(syn)|(syo)|(syr)|(sys)|(syw)|(syx)|(syy)|(sza)|(szb)|(szc)|(szd)|(sze)|(szg)|(szl)|(szn)|(szp)|(szs)|(szv)|(szw)|(taa)|(tab)|(tac)|(tad)|(tae)|(taf)|(tag)|(tai)|(taj)|(tak)|(tal)|(tan)|(tao)|(tap)|(taq)|(tar)|(tas)|(tau)|(tav)|(taw)|(tax)|(tay)|(taz)|(tba)|(tbb)|(tbc)|(tbd)|(tbe)|(tbf)|(tbg)|(tbh)|(tbi)|(tbj)|(tbk)|(tbl)|(tbm)|(tbn)|(tbo)|(tbp)|(tbq)|(tbr)|(tbs)|(tbt)|(tbu)|(tbv)|(tbw)|(tbx)|(tby)|(tbz)|(tca)|(tcb)|(tcc)|(tcd)|(tce)|(tcf)|(tcg)|(tch)|(tci)|(tck)|(tcl)|(tcm)|(tcn)|(tco)|(tcp)|(tcq)|(tcs)|(tct)|(tcu)|(tcw)|(tcx)|(tcy)|(tcz)|(tda)|(tdb)|(tdc)|(tdd)|(tde)|(tdf)|(tdg)|(tdh)|(tdi)|(tdj)|(tdk)|(tdl)|(tdm)|(tdn)|(tdo)|(tdq)|(tdr)|(tds)|(tdt)|(tdu)|(tdv)|(tdx)|(tdy)|(tea)|(teb)|(tec)|(ted)|(tee)|(tef)|(teg)|(teh)|(tei)|(tek)|(tem)|(ten)|(teo)|(tep)|(teq)|(ter)|(tes)|(tet)|(teu)|(tev)|(tew)|(tex)|(tey)|(tfi)|(tfn)|(tfo)|(tfr)|(tft)|(tga)|(tgb)|(tgc)|(tgd)|(tge)|(tgf)|(tgg)|(tgh)|(tgi)|(tgj)|(tgn)|(tgo)|(tgp)|(tgq)|(tgr)|(tgs)|(tgt)|(tgu)|(tgv)|(tgw)|(tgx)|(tgy)|(tgz)|(thc)|(thd)|(the)|(thf)|(thh)|(thi)|(thk)|(thl)|(thm)|(thn)|(thp)|(thq)|(thr)|(ths)|(tht)|(thu)|(thv)|(thw)|(thx)|(thy)|(thz)|(tia)|(tic)|(tid)|(tie)|(tif)|(tig)|(tih)|(tii)|(tij)|(tik)|(til)|(tim)|(tin)|(tio)|(tip)|(tiq)|(tis)|(tit)|(tiu)|(tiv)|(tiw)|(tix)|(tiy)|(tiz)|(tja)|(tjg)|(tji)|(tjl)|(tjm)|(tjn)|(tjo)|(tjs)|(tju)|(tjw)|(tka)|(tkb)|(tkd)|(tke)|(tkf)|(tkg)|(tkk)|(tkl)|(tkm)|(tkn)|(tkp)|(tkq)|(tkr)|(tks)|(tkt)|(tku)|(tkv)|(tkw)|(tkx)|(tkz)|(tla)|(tlb)|(tlc)|(tld)|(tlf)|(tlg)|(tlh)|(tli)|(tlj)|(tlk)|(tll)|(tlm)|(tln)|(tlo)|(tlp)|(tlq)|(tlr)|(tls)|(tlt)|(tlu)|(tlv)|(tlw)|(tlx)|(tly)|(tma)|(tmb)|(tmc)|(tmd)|(tme)|(tmf)|(tmg)|(tmh)|(tmi)|(tmj)|(tmk)|(tml)|(tmm)|(tmn)|(tmo)|(tmp)|(tmq)|(tmr)|(tms)|(tmt)|(tmu)|(tmv)|(tmw)|(tmy)|(tmz)|(tna)|(tnb)|(tnc)|(tnd)|(tne)|(tnf)|(tng)|(tnh)|(tni)|(tnk)|(tnl)|(tnm)|(tnn)|(tno)|(tnp)|(tnq)|(tnr)|(tns)|(tnt)|(tnu)|(tnv)|(tnw)|(tnx)|(tny)|(tnz)|(tob)|(toc)|(tod)|(toe)|(tof)|(tog)|(toh)|(toi)|(toj)|(tol)|(tom)|(too)|(top)|(toq)|(tor)|(tos)|(tou)|(tov)|(tow)|(tox)|(toy)|(toz)|(tpa)|(tpc)|(tpe)|(tpf)|(tpg)|(tpi)|(tpj)|(tpk)|(tpl)|(tpm)|(tpn)|(tpo)|(tpp)|(tpq)|(tpr)|(tpt)|(tpu)|(tpv)|(tpw)|(tpx)|(tpy)|(tpz)|(tqb)|(tql)|(tqm)|(tqn)|(tqo)|(tqp)|(tqq)|(tqr)|(tqt)|(tqu)|(tqw)|(tra)|(trb)|(trc)|(trd)|(tre)|(trf)|(trg)|(trh)|(tri)|(trj)|(trk)|(trl)|(trm)|(trn)|(tro)|(trp)|(trq)|(trr)|(trs)|(trt)|(tru)|(trv)|(trw)|(trx)|(try)|(trz)|(tsa)|(tsb)|(tsc)|(tsd)|(tse)|(tsf)|(tsg)|(tsh)|(tsi)|(tsj)|(tsk)|(tsl)|(tsm)|(tsp)|(tsq)|(tsr)|(tss)|(tst)|(tsu)|(tsv)|(tsw)|(tsx)|(tsy)|(tsz)|(tta)|(ttb)|(ttc)|(ttd)|(tte)|(ttf)|(ttg)|(tth)|(tti)|(ttj)|(ttk)|(ttl)|(ttm)|(ttn)|(tto)|(ttp)|(ttq)|(ttr)|(tts)|(ttt)|(ttu)|(ttv)|(ttw)|(tty)|(ttz)|(tua)|(tub)|(tuc)|(tud)|(tue)|(tuf)|(tug)|(tuh)|(tui)|(tuj)|(tul)|(tum)|(tun)|(tuo)|(tup)|(tuq)|(tus)|(tut)|(tuu)|(tuv)|(tuw)|(tux)|(tuy)|(tuz)|(tva)|(tvd)|(tve)|(tvk)|(tvl)|(tvm)|(tvn)|(tvo)|(tvs)|(tvt)|(tvu)|(tvw)|(tvy)|(twa)|(twb)|(twc)|(twd)|(twe)|(twf)|(twg)|(twh)|(twl)|(twm)|(twn)|(two)|(twp)|(twq)|(twr)|(twt)|(twu)|(tww)|(twx)|(twy)|(txa)|(txb)|(txc)|(txe)|(txg)|(txh)|(txi)|(txj)|(txm)|(txn)|(txo)|(txq)|(txr)|(txs)|(txt)|(txu)|(txx)|(txy)|(tya)|(tye)|(tyh)|(tyi)|(tyj)|(tyl)|(tyn)|(typ)|(tyr)|(tys)|(tyt)|(tyu)|(tyv)|(tyx)|(tyz)|(tza)|(tzh)|(tzj)|(tzl)|(tzm)|(tzn)|(tzo)|(tzx)|(uam)|(uan)|(uar)|(uba)|(ubi)|(ubl)|(ubr)|(ubu)|(uby)|(uda)|(ude)|(udg)|(udi)|(udj)|(udl)|(udm)|(udu)|(ues)|(ufi)|(uga)|(ugb)|(uge)|(ugn)|(ugo)|(ugy)|(uha)|(uhn)|(uis)|(uiv)|(uji)|(uka)|(ukg)|(ukh)|(ukk)|(ukl)|(ukp)|(ukq)|(uks)|(uku)|(ukw)|(uky)|(ula)|(ulb)|(ulc)|(ule)|(ulf)|(uli)|(ulk)|(ull)|(ulm)|(uln)|(ulu)|(ulw)|(uma)|(umb)|(umc)|(umd)|(umg)|(umi)|(umm)|(umn)|(umo)|(ump)|(umr)|(ums)|(umu)|(una)|(und)|(une)|(ung)|(unk)|(unm)|(unn)|(unp)|(unr)|(unu)|(unx)|(unz)|(uok)|(upi)|(upv)|(ura)|(urb)|(urc)|(ure)|(urf)|(urg)|(urh)|(uri)|(urj)|(urk)|(url)|(urm)|(urn)|(uro)|(urp)|(urr)|(urt)|(uru)|(urv)|(urw)|(urx)|(ury)|(urz)|(usa)|(ush)|(usi)|(usk)|(usp)|(usu)|(uta)|(ute)|(utp)|(utr)|(utu)|(uum)|(uun)|(uur)|(uuu)|(uve)|(uvh)|(uvl)|(uwa)|(uya)|(uzn)|(uzs)|(vaa)|(vae)|(vaf)|(vag)|(vah)|(vai)|(vaj)|(val)|(vam)|(van)|(vao)|(vap)|(var)|(vas)|(vau)|(vav)|(vay)|(vbb)|(vbk)|(vec)|(ved)|(vel)|(vem)|(veo)|(vep)|(ver)|(vgr)|(vgt)|(vic)|(vid)|(vif)|(vig)|(vil)|(vin)|(vis)|(vit)|(viv)|(vka)|(vki)|(vkj)|(vkk)|(vkl)|(vkm)|(vko)|(vkp)|(vkt)|(vku)|(vlp)|(vls)|(vma)|(vmb)|(vmc)|(vmd)|(vme)|(vmf)|(vmg)|(vmh)|(vmi)|(vmj)|(vmk)|(vml)|(vmm)|(vmp)|(vmq)|(vmr)|(vms)|(vmu)|(vmv)|(vmw)|(vmx)|(vmy)|(vmz)|(vnk)|(vnm)|(vnp)|(vor)|(vot)|(vra)|(vro)|(vrs)|(vrt)|(vsi)|(vsl)|(vsv)|(vto)|(vum)|(vun)|(vut)|(vwa)|(waa)|(wab)|(wac)|(wad)|(wae)|(waf)|(wag)|(wah)|(wai)|(waj)|(wak)|(wal)|(wam)|(wan)|(wao)|(wap)|(waq)|(war)|(was)|(wat)|(wau)|(wav)|(waw)|(wax)|(way)|(waz)|(wba)|(wbb)|(wbe)|(wbf)|(wbh)|(wbi)|(wbj)|(wbk)|(wbl)|(wbm)|(wbp)|(wbq)|(wbr)|(wbs)|(wbt)|(wbv)|(wbw)|(wca)|(wci)|(wdd)|(wdg)|(wdj)|(wdk)|(wdu)|(wdy)|(wea)|(wec)|(wed)|(weg)|(weh)|(wei)|(wem)|(wen)|(weo)|(wep)|(wer)|(wes)|(wet)|(weu)|(wew)|(wfg)|(wga)|(wgb)|(wgg)|(wgi)|(wgo)|(wgu)|(wgw)|(wgy)|(wha)|(whg)|(whk)|(whu)|(wib)|(wic)|(wie)|(wif)|(wig)|(wih)|(wii)|(wij)|(wik)|(wil)|(wim)|(win)|(wir)|(wit)|(wiu)|(wiv)|(wiw)|(wiy)|(wja)|(wji)|(wka)|(wkb)|(wkd)|(wkl)|(wku)|(wkw)|(wky)|(wla)|(wlc)|(wle)|(wlg)|(wli)|(wlk)|(wll)|(wlm)|(wlo)|(wlr)|(wls)|(wlu)|(wlv)|(wlw)|(wlx)|(wly)|(wma)|(wmb)|(wmc)|(wmd)|(wme)|(wmh)|(wmi)|(wmm)|(wmn)|(wmo)|(wms)|(wmt)|(wmw)|(wmx)|(wnb)|(wnc)|(wnd)|(wne)|(wng)|(wni)|(wnk)|(wnm)|(wnn)|(wno)|(wnp)|(wnu)|(wnw)|(wny)|(woa)|(wob)|(woc)|(wod)|(woe)|(wof)|(wog)|(woi)|(wok)|(wom)|(won)|(woo)|(wor)|(wos)|(wow)|(woy)|(wpc)|(wra)|(wrb)|(wrd)|(wrg)|(wrh)|(wri)|(wrk)|(wrl)|(wrm)|(wrn)|(wro)|(wrp)|(wrr)|(wrs)|(wru)|(wrv)|(wrw)|(wrx)|(wry)|(wrz)|(wsa)|(wsg)|(wsi)|(wsk)|(wsr)|(wss)|(wsu)|(wsv)|(wtf)|(wth)|(wti)|(wtk)|(wtm)|(wtw)|(wua)|(wub)|(wud)|(wuh)|(wul)|(wum)|(wun)|(wur)|(wut)|(wuu)|(wuv)|(wux)|(wuy)|(wwa)|(wwb)|(wwo)|(wwr)|(www)|(wxa)|(wxw)|(wya)|(wyb)|(wyi)|(wym)|(wyr)|(wyy)|(xaa)|(xab)|(xac)|(xad)|(xae)|(xag)|(xai)|(xaj)|(xak)|(xal)|(xam)|(xan)|(xao)|(xap)|(xaq)|(xar)|(xas)|(xat)|(xau)|(xav)|(xaw)|(xay)|(xba)|(xbb)|(xbc)|(xbd)|(xbe)|(xbg)|(xbi)|(xbj)|(xbm)|(xbn)|(xbo)|(xbp)|(xbr)|(xbw)|(xbx)|(xby)|(xcb)|(xcc)|(xce)|(xcg)|(xch)|(xcl)|(xcm)|(xcn)|(xco)|(xcr)|(xct)|(xcu)|(xcv)|(xcw)|(xcy)|(xda)|(xdc)|(xdk)|(xdm)|(xdo)|(xdy)|(xeb)|(xed)|(xeg)|(xel)|(xem)|(xep)|(xer)|(xes)|(xet)|(xeu)|(xfa)|(xga)|(xgb)|(xgd)|(xgf)|(xgg)|(xgi)|(xgl)|(xgm)|(xgn)|(xgr)|(xgu)|(xgw)|(xha)|(xhc)|(xhd)|(xhe)|(xhr)|(xht)|(xhu)|(xhv)|(xia)|(xib)|(xii)|(xil)|(xin)|(xip)|(xir)|(xis)|(xiv)|(xiy)|(xjb)|(xjt)|(xka)|(xkb)|(xkc)|(xkd)|(xke)|(xkf)|(xkg)|(xkh)|(xki)|(xkj)|(xkk)|(xkl)|(xkn)|(xko)|(xkp)|(xkq)|(xkr)|(xks)|(xkt)|(xku)|(xkv)|(xkw)|(xkx)|(xky)|(xkz)|(xla)|(xlb)|(xlc)|(xld)|(xle)|(xlg)|(xli)|(xln)|(xlo)|(xlp)|(xls)|(xlu)|(xly)|(xma)|(xmb)|(xmc)|(xmd)|(xme)|(xmf)|(xmg)|(xmh)|(xmj)|(xmk)|(xml)|(xmm)|(xmn)|(xmo)|(xmp)|(xmq)|(xmr)|(xms)|(xmt)|(xmu)|(xmv)|(xmw)|(xmx)|(xmy)|(xmz)|(xna)|(xnb)|(xnd)|(xng)|(xnh)|(xni)|(xnk)|(xnn)|(xno)|(xnr)|(xns)|(xnt)|(xnu)|(xny)|(xnz)|(xoc)|(xod)|(xog)|(xoi)|(xok)|(xom)|(xon)|(xoo)|(xop)|(xor)|(xow)|(xpa)|(xpc)|(xpe)|(xpg)|(xpi)|(xpj)|(xpk)|(xpm)|(xpn)|(xpo)|(xpp)|(xpq)|(xpr)|(xps)|(xpt)|(xpu)|(xpy)|(xqa)|(xqt)|(xra)|(xrb)|(xrd)|(xre)|(xrg)|(xri)|(xrm)|(xrn)|(xrq)|(xrr)|(xrt)|(xru)|(xrw)|(xsa)|(xsb)|(xsc)|(xsd)|(xse)|(xsh)|(xsi)|(xsj)|(xsl)|(xsm)|(xsn)|(xso)|(xsp)|(xsq)|(xsr)|(xss)|(xsu)|(xsv)|(xsy)|(xta)|(xtb)|(xtc)|(xtd)|(xte)|(xtg)|(xth)|(xti)|(xtj)|(xtl)|(xtm)|(xtn)|(xto)|(xtp)|(xtq)|(xtr)|(xts)|(xtt)|(xtu)|(xtv)|(xtw)|(xty)|(xtz)|(xua)|(xub)|(xud)|(xug)|(xuj)|(xul)|(xum)|(xun)|(xuo)|(xup)|(xur)|(xut)|(xuu)|(xve)|(xvi)|(xvn)|(xvo)|(xvs)|(xwa)|(xwc)|(xwd)|(xwe)|(xwg)|(xwj)|(xwk)|(xwl)|(xwo)|(xwr)|(xwt)|(xww)|(xxb)|(xxk)|(xxm)|(xxr)|(xxt)|(xya)|(xyb)|(xyj)|(xyk)|(xyl)|(xyt)|(xyy)|(xzh)|(xzm)|(xzp)|(yaa)|(yab)|(yac)|(yad)|(yae)|(yaf)|(yag)|(yah)|(yai)|(yaj)|(yak)|(yal)|(yam)|(yan)|(yao)|(yap)|(yaq)|(yar)|(yas)|(yat)|(yau)|(yav)|(yaw)|(yax)|(yay)|(yaz)|(yba)|(ybb)|(ybd)|(ybe)|(ybh)|(ybi)|(ybj)|(ybk)|(ybl)|(ybm)|(ybn)|(ybo)|(ybx)|(yby)|(ych)|(ycl)|(ycn)|(ycp)|(yda)|(ydd)|(yde)|(ydg)|(ydk)|(yds)|(yea)|(yec)|(yee)|(yei)|(yej)|(yel)|(yen)|(yer)|(yes)|(yet)|(yeu)|(yev)|(yey)|(yga)|(ygi)|(ygl)|(ygm)|(ygp)|(ygr)|(ygs)|(ygu)|(ygw)|(yha)|(yhd)|(yhl)|(yhs)|(yia)|(yif)|(yig)|(yih)|(yii)|(yij)|(yik)|(yil)|(yim)|(yin)|(yip)|(yiq)|(yir)|(yis)|(yit)|(yiu)|(yiv)|(yix)|(yiy)|(yiz)|(yka)|(ykg)|(yki)|(ykk)|(ykl)|(ykm)|(ykn)|(yko)|(ykr)|(ykt)|(yku)|(yky)|(yla)|(ylb)|(yle)|(ylg)|(yli)|(yll)|(ylm)|(yln)|(ylo)|(ylr)|(ylu)|(yly)|(yma)|(ymb)|(ymc)|(ymd)|(yme)|(ymg)|(ymh)|(ymi)|(ymk)|(yml)|(ymm)|(ymn)|(ymo)|(ymp)|(ymq)|(ymr)|(yms)|(ymt)|(ymx)|(ymz)|(yna)|(ynd)|(yne)|(yng)|(ynh)|(ynk)|(ynl)|(ynn)|(yno)|(ynq)|(yns)|(ynu)|(yob)|(yog)|(yoi)|(yok)|(yol)|(yom)|(yon)|(yos)|(yot)|(yox)|(yoy)|(ypa)|(ypb)|(ypg)|(yph)|(ypk)|(ypm)|(ypn)|(ypo)|(ypp)|(ypz)|(yra)|(yrb)|(yre)|(yri)|(yrk)|(yrl)|(yrm)|(yrn)|(yro)|(yrs)|(yrw)|(yry)|(ysc)|(ysd)|(ysg)|(ysl)|(ysn)|(yso)|(ysp)|(ysr)|(yss)|(ysy)|(yta)|(ytl)|(ytp)|(ytw)|(yty)|(yua)|(yub)|(yuc)|(yud)|(yue)|(yuf)|(yug)|(yui)|(yuj)|(yuk)|(yul)|(yum)|(yun)|(yup)|(yuq)|(yur)|(yut)|(yuu)|(yuw)|(yux)|(yuy)|(yuz)|(yva)|(yvt)|(ywa)|(ywg)|(ywl)|(ywn)|(ywq)|(ywr)|(ywt)|(ywu)|(yww)|(yxa)|(yxg)|(yxl)|(yxm)|(yxu)|(yxy)|(yyr)|(yyu)|(yyz)|(yzg)|(yzk)|(zaa)|(zab)|(zac)|(zad)|(zae)|(zaf)|(zag)|(zah)|(zai)|(zaj)|(zak)|(zal)|(zam)|(zao)|(zap)|(zaq)|(zar)|(zas)|(zat)|(zau)|(zav)|(zaw)|(zax)|(zay)|(zaz)|(zbc)|(zbe)|(zbl)|(zbt)|(zbw)|(zca)|(zch)|(zdj)|(zea)|(zeg)|(zeh)|(zen)|(zga)|(zgb)|(zgh)|(zgm)|(zgn)|(zgr)|(zhb)|(zhd)|(zhi)|(zhn)|(zhw)|(zhx)|(zia)|(zib)|(zik)|(zil)|(zim)|(zin)|(zir)|(ziw)|(ziz)|(zka)|(zkb)|(zkd)|(zkg)|(zkh)|(zkk)|(zkn)|(zko)|(zkp)|(zkr)|(zkt)|(zku)|(zkv)|(zkz)|(zle)|(zlj)|(zlm)|(zln)|(zlq)|(zls)|(zlw)|(zma)|(zmb)|(zmc)|(zmd)|(zme)|(zmf)|(zmg)|(zmh)|(zmi)|(zmj)|(zmk)|(zml)|(zmm)|(zmn)|(zmo)|(zmp)|(zmq)|(zmr)|(zms)|(zmt)|(zmu)|(zmv)|(zmw)|(zmx)|(zmy)|(zmz)|(zna)|(znd)|(zne)|(zng)|(znk)|(zns)|(zoc)|(zoh)|(zom)|(zoo)|(zoq)|(zor)|(zos)|(zpa)|(zpb)|(zpc)|(zpd)|(zpe)|(zpf)|(zpg)|(zph)|(zpi)|(zpj)|(zpk)|(zpl)|(zpm)|(zpn)|(zpo)|(zpp)|(zpq)|(zpr)|(zps)|(zpt)|(zpu)|(zpv)|(zpw)|(zpx)|(zpy)|(zpz)|(zqe)|(zra)|(zrg)|(zrn)|(zro)|(zrp)|(zrs)|(zsa)|(zsk)|(zsl)|(zsm)|(zsr)|(zsu)|(zte)|(ztg)|(ztl)|(ztm)|(ztn)|(ztp)|(ztq)|(zts)|(ztt)|(ztu)|(ztx)|(zty)|(zua)|(zuh)|(zum)|(zun)|(zuy)|(zwa)|(zxx)|(zyb)|(zyg)|(zyj)|(zyn)|(zyp)|(zza)|(zzj))(\-((aao)|(abh)|(abv)|(acm)|(acq)|(acw)|(acx)|(acy)|(adf)|(ads)|(aeb)|(aec)|(aed)|(aen)|(afb)|(afg)|(ajp)|(apc)|(apd)|(arb)|(arq)|(ars)|(ary)|(arz)|(ase)|(asf)|(asp)|(asq)|(asw)|(auz)|(avl)|(ayh)|(ayl)|(ayn)|(ayp)|(bbz)|(bfi)|(bfk)|(bjn)|(bog)|(bqn)|(bqy)|(btj)|(bve)|(bvl)|(bvu)|(bzs)|(cdo)|(cds)|(cjy)|(cmn)|(coa)|(cpx)|(csc)|(csd)|(cse)|(csf)|(csg)|(csl)|(csn)|(csq)|(csr)|(czh)|(czo)|(doq)|(dse)|(dsl)|(dup)|(ecs)|(esl)|(esn)|(eso)|(eth)|(fcs)|(fse)|(fsl)|(fss)|(gan)|(gds)|(gom)|(gse)|(gsg)|(gsm)|(gss)|(gus)|(hab)|(haf)|(hak)|(hds)|(hji)|(hks)|(hos)|(hps)|(hsh)|(hsl)|(hsn)|(icl)|(iks)|(ils)|(inl)|(ins)|(ise)|(isg)|(isr)|(jak)|(jax)|(jcs)|(jhs)|(jls)|(jos)|(jsl)|(jus)|(kgi)|(knn)|(kvb)|(kvk)|(kvr)|(kxd)|(lbs)|(lce)|(lcf)|(liw)|(lls)|(lsg)|(lsl)|(lso)|(lsp)|(lst)|(lsy)|(ltg)|(lvs)|(lzh)|(max)|(mdl)|(meo)|(mfa)|(mfb)|(mfs)|(min)|(mnp)|(mqg)|(mre)|(msd)|(msi)|(msr)|(mui)|(mzc)|(mzg)|(mzy)|(nan)|(nbs)|(ncs)|(nsi)|(nsl)|(nsp)|(nsr)|(nzs)|(okl)|(orn)|(ors)|(pel)|(pga)|(pgz)|(pks)|(prl)|(prz)|(psc)|(psd)|(pse)|(psg)|(psl)|(pso)|(psp)|(psr)|(pys)|(rms)|(rsi)|(rsl)|(rsm)|(sdl)|(sfb)|(sfs)|(sgg)|(sgx)|(shu)|(slf)|(sls)|(sqk)|(sqs)|(ssh)|(ssp)|(ssr)|(svk)|(swc)|(swh)|(swl)|(syy)|(szs)|(tmw)|(tse)|(tsm)|(tsq)|(tss)|(tsy)|(tza)|(ugn)|(ugy)|(ukl)|(uks)|(urk)|(uzn)|(uzs)|(vgt)|(vkk)|(vkt)|(vsi)|(vsl)|(vsv)|(wbs)|(wuu)|(xki)|(xml)|(xmm)|(xms)|(yds)|(ygs)|(yhs)|(ysl)|(yue)|(zib)|(zlm)|(zmi)|(zsl)|(zsm)))?(\-((Adlm)|(Afak)|(Aghb)|(Ahom)|(Arab)|(Aran)|(Armi)|(Armn)|(Avst)|(Bali)|(Bamu)|(Bass)|(Batk)|(Beng)|(Bhks)|(Blis)|(Bopo)|(Brah)|(Brai)|(Bugi)|(Buhd)|(Cakm)|(Cans)|(Cari)|(Cham)|(Cher)|(Cirt)|(Copt)|(Cprt)|(Cyrl)|(Cyrs)|(Deva)|(Dogr)|(Dsrt)|(Dupl)|(Egyd)|(Egyh)|(Egyp)|(Elba)|(Ethi)|(Geok)|(Geor)|(Glag)|(Gong)|(Gonm)|(Goth)|(Gran)|(Grek)|(Gujr)|(Guru)|(Hanb)|(Hang)|(Hani)|(Hano)|(Hans)|(Hant)|(Hatr)|(Hebr)|(Hira)|(Hluw)|(Hmng)|(Hrkt)|(Hung)|(Inds)|(Ital)|(Jamo)|(Java)|(Jpan)|(Jurc)|(Kali)|(Kana)|(Khar)|(Khmr)|(Khoj)|(Kitl)|(Kits)|(Knda)|(Kore)|(Kpel)|(Kthi)|(Lana)|(Laoo)|(Latf)|(Latg)|(Latn)|(Leke)|(Lepc)|(Limb)|(Lina)|(Linb)|(Lisu)|(Loma)|(Lyci)|(Lydi)|(Mahj)|(Maka)|(Mand)|(Mani)|(Marc)|(Maya)|(Medf)|(Mend)|(Merc)|(Mero)|(Mlym)|(Modi)|(Mong)|(Moon)|(Mroo)|(Mtei)|(Mult)|(Mymr)|(Narb)|(Nbat)|(Newa)|(Nkgb)|(Nkoo)|(Nshu)|(Ogam)|(Olck)|(Orkh)|(Orya)|(Osge)|(Osma)|(Palm)|(Pauc)|(Perm)|(Phag)|(Phli)|(Phlp)|(Phlv)|(Phnx)|(Piqd)|(Plrd)|(Prti)|(Qaaa..Qabx)|(Rjng)|(Roro)|(Runr)|(Samr)|(Sara)|(Sarb)|(Saur)|(Sgnw)|(Shaw)|(Shrd)|(Sidd)|(Sind)|(Sinh)|(Sora)|(Soyo)|(Sund)|(Sylo)|(Syrc)|(Syre)|(Syrj)|(Syrn)|(Tagb)|(Takr)|(Tale)|(Talu)|(Taml)|(Tang)|(Tavt)|(Telu)|(Teng)|(Tfng)|(Tglg)|(Thaa)|(Thai)|(Tibt)|(Tirh)|(Ugar)|(Vaii)|(Visp)|(Wara)|(Wole)|(Xpeo)|(Xsux)|(Yiii)|(Zanb)|(Zinh)|(Zmth)|(Zsye)|(Zsym)|(Zxxx)|(Zyyy)|(Zzzz)))?(\-((AA)|(AC)|(AD)|(AE)|(AF)|(AG)|(AI)|(AL)|(AM)|(AN)|(AO)|(AQ)|(AR)|(AS)|(AT)|(AU)|(AW)|(AX)|(AZ)|(BA)|(BB)|(BD)|(BE)|(BF)|(BG)|(BH)|(BI)|(BJ)|(BL)|(BM)|(BN)|(BO)|(BQ)|(BR)|(BS)|(BT)|(BU)|(BV)|(BW)|(BY)|(BZ)|(CA)|(CC)|(CD)|(CF)|(CG)|(CH)|(CI)|(CK)|(CL)|(CM)|(CN)|(CO)|(CP)|(CR)|(CS)|(CU)|(CV)|(CW)|(CX)|(CY)|(CZ)|(DD)|(DE)|(DG)|(DJ)|(DK)|(DM)|(DO)|(DZ)|(EA)|(EC)|(EE)|(EG)|(EH)|(ER)|(ES)|(ET)|(EU)|(EZ)|(FI)|(FJ)|(FK)|(FM)|(FO)|(FR)|(FX)|(GA)|(GB)|(GD)|(GE)|(GF)|(GG)|(GH)|(GI)|(GL)|(GM)|(GN)|(GP)|(GQ)|(GR)|(GS)|(GT)|(GU)|(GW)|(GY)|(HK)|(HM)|(HN)|(HR)|(HT)|(HU)|(IC)|(ID)|(IE)|(IL)|(IM)|(IN)|(IO)|(IQ)|(IR)|(IS)|(IT)|(JE)|(JM)|(JO)|(JP)|(KE)|(KG)|(KH)|(KI)|(KM)|(KN)|(KP)|(KR)|(KW)|(KY)|(KZ)|(LA)|(LB)|(LC)|(LI)|(LK)|(LR)|(LS)|(LT)|(LU)|(LV)|(LY)|(MA)|(MC)|(MD)|(ME)|(MF)|(MG)|(MH)|(MK)|(ML)|(MM)|(MN)|(MO)|(MP)|(MQ)|(MR)|(MS)|(MT)|(MU)|(MV)|(MW)|(MX)|(MY)|(MZ)|(NA)|(NC)|(NE)|(NF)|(NG)|(NI)|(NL)|(NO)|(NP)|(NR)|(NT)|(NU)|(NZ)|(OM)|(PA)|(PE)|(PF)|(PG)|(PH)|(PK)|(PL)|(PM)|(PN)|(PR)|(PS)|(PT)|(PW)|(PY)|(QA)|(QM..QZ)|(RE)|(RO)|(RS)|(RU)|(RW)|(SA)|(SB)|(SC)|(SD)|(SE)|(SG)|(SH)|(SI)|(SJ)|(SK)|(SL)|(SM)|(SN)|(SO)|(SR)|(SS)|(ST)|(SU)|(SV)|(SX)|(SY)|(SZ)|(TA)|(TC)|(TD)|(TF)|(TG)|(TH)|(TJ)|(TK)|(TL)|(TM)|(TN)|(TO)|(TP)|(TR)|(TT)|(TV)|(TW)|(TZ)|(UA)|(UG)|(UM)|(UN)|(US)|(UY)|(UZ)|(VA)|(VC)|(VE)|(VG)|(VI)|(VN)|(VU)|(WF)|(WS)|(XA..XZ)|(YD)|(YE)|(YT)|(YU)|(ZA)|(ZM)|(ZR)|(ZW)|(ZZ)|(001)|(002)|(003)|(005)|(009)|(011)|(013)|(014)|(015)|(017)|(018)|(019)|(021)|(029)|(030)|(034)|(035)|(039)|(053)|(054)|(057)|(061)|(142)|(143)|(145)|(150)|(151)|(154)|(155)|(419)))?(\-((1606nict)|(1694acad)|(1901)|(1959acad)|(1994)|(1996)|(abl1943)|(alalc97)|(aluku)|(ao1990)|(arevela)|(arevmda)|(baku1926)|(balanka)|(barla)|(basiceng)|(bauddha)|(biscayan)|(biske)|(bohoric)|(boont)|(colb1945)|(cornu)|(dajnko)|(ekavsk)|(emodeng)|(fonipa)|(fonnapa)|(fonupa)|(fonxsamp)|(hepburn)|(heploc)|(hognorsk)|(ijekavsk)|(itihasa)|(jauer)|(jyutping)|(kkcor)|(kociewie)|(kscor)|(laukika)|(lipaw)|(luna1918)|(metelko)|(monoton)|(ndyuka)|(nedis)|(newfound)|(njiva)|(nulik)|(osojs)|(oxendict)|(pahawh2)|(pahawh3)|(pahawh4)|(pamaka)|(petr1708)|(pinyin)|(polyton)|(puter)|(rigik)|(rozaj)|(rumgr)|(scotland)|(scouse)|(simple)|(solba)|(sotav)|(spanglis)|(surmiran)|(sursilv)|(sutsilv)|(tarask)|(uccor)|(ucrcor)|(ulster)|(unifon)|(vaidika)|(valencia)|(vallader)|(wadegile)))?($|\-)</xsl:variable>
    
<!--    TODO: Create template for creating diagnostics checks divs, so that
    this document is easily expandable (following the model of Moses/MoEML diagnostics.-->

    <xd:doc scope="component">
        <xd:desc>This key indexes all @xml:id attributes that might be pointed at
        using a fully-expanded path to their container document followed by '#[id]'.
        When idrefs are encountered in documents, they too are fully expanded before
        being checked against the key. If there's no match in the key, presumably 
        the idref is wrong.</xd:desc>
    </xd:doc>
    <xsl:key name="declaredIds" match="*/@xml:id"
        use="normalize-space(concat(document-uri(root(.)), '#', .))"/>
    
    <xd:doc scope="component">
        <xd:desc>This key is used to index all prefixDefs in a project so that 
            their expansion regexes can be retrieved and used easily.
        </xd:desc>
    </xd:doc>
    <xsl:key name="prefixDefs" match="prefixDef" use="@ident"/>
    
    <xsl:template match="/">
        <xsl:message>Running diagnostics...</xsl:message>
        <xsl:result-document href="file:///{translate($outputDirectory, '\', '/')}/diagnostics.html">
            <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;
            </xsl:text>
            <html>
                <head>
                    <title>Diagnostics for project at <xsl:value-of select="$projectDirectory"/></title>
                    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
                    <xsl:copy-of select="$javascript"/>
                    <xsl:copy-of select="$css"/>
                </head>
                <body>
                    <h1>Diagnostics for project at <xsl:value-of select="$projectDirectory"/></h1>
                    <div>
                        <xsl:call-template name="generateStatistics"/>
                        <xsl:call-template name="generateDiagnosticChecks"/>
                    </div>
                    <p class="timestamp">Last generated: <xsl:value-of select="current-dateTime()"/></p>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <!--************** STATISTICS ********************-->
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="generateStatistics" type="template"/>
            <xd:p>This template generates a number of statistics about the project.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="generateStatistics">
        <xsl:variable name="teiDocCount" select="count($teiDocs)"/>
        <xsl:variable name="teiDocsDeclaredIdsCount" select="count($teiDocs/descendant-or-self::*/@xml:id)"/>
        
        <xsl:message>TEI doc count: <xsl:value-of select="$teiDocCount"/>&#x0a;@xml:id count: <xsl:value-of select="$teiDocsDeclaredIdsCount"/></xsl:message>
        
        <div class="showing">
            <h2 onclick="showHide(this)">Statistics</h2>
            <table>
                <tbody>
                    <tr><td>TEI documents</td><td><xsl:value-of select="$teiDocCount"/></td></tr>
                    <tr><td>Declared <span class="attName">xml:id</span>s</td><td><xsl:value-of select="$teiDocsDeclaredIdsCount"/></td></tr>
                </tbody>
            </table>
            <xsl:call-template name="elementsUsed"/>
            <xsl:call-template name="attributesUsed"/>
        </div>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:ref name="elementsUsed" type="template"/>
            <xd:p>This template compiles various statistics about the 
                elements used in the project.</xd:p>
        </xd:desc>
        <xd:return>
            <xd:p>An XHTML &lt;div&gt;.</xd:p>
        </xd:return>
    </xd:doc>
    <xsl:template name="elementsUsed" as="element(xh:div)">
        <xsl:variable name="allElements" select="$teiDocs/descendant-or-self::*"/>
        <xsl:variable name="allElementsNames" select="for $n in $allElements return local-name($n)"/>
        <xsl:variable name="distinctElements" select="distinct-values($allElementsNames)" as="xs:string+"/>
        <div class="hidden">
            <h3 onclick="showHide(this)">Elements used</h3>
            <table>
                <tbody>
                    <tr>
                        <td>Distinct elements</td>
                        <td><xsl:value-of select="count($distinctElements)"/></td>
                    </tr>
                </tbody>
            </table>
            <table>
                <thead>
                    <tr>
                        <td>Element name</td>
                        <td>Number of times element used</td>
                        <td>Number of documents containing this element</td>
                        <td>Average number of uses per document</td>
                        <td>TEI Guidelines</td>
                    </tr>
                </thead>
                <tbody>
                    <!--Create a row for each element-->
                    <xsl:for-each select="$distinctElements">
                        <xsl:sort order="ascending" select="lower-case(.)"/>
                        <xsl:variable name="thisElementName" select="."/>
                        
                        <!--Which TEI docs contain this element-->
                        <xsl:variable
                            name="docsContainingThisElement"
                            select="$teiDocs[descendant-or-self::*[local-name()=$thisElementName]]"/>
                        
                        <!--How many documents use this element-->
                        <xsl:variable 
                            name="totalDocs"
                            select="count($docsContainingThisElement)"/>
                        
                        <!--How many times is the element referenced across the project-->
                        <xsl:variable
                            name="totalElement"
                            select="count($teiDocs/descendant-or-self::*[local-name()=$thisElementName])"/>
                        
                        <!--Calculated average of uses per document-->
                        <xsl:variable
                            name="averageUses"
                            select="$totalElement div $totalDocs"/>
                        
                        <tr>
                            <td><span class="xmlTag"><xsl:value-of select="$thisElementName"/></span></td>
                            <td><xsl:value-of select="$totalElement"/></td>
                            <td><xsl:value-of select="$totalDocs"/></td>
                            <td><xsl:value-of select="format-number($averageUses,'#.###')"/></td>
                            <td><a href="http://tei-c.org/release/doc/tei-p5-doc/en/html/ref-{$thisElementName}.html">TEI</a></td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </div>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="attributesUsed" type="template"/>
            <xd:p>This template compiles various statistics about the
                attributes used in the project.</xd:p>
        </xd:desc>
        <xd:return>
            <xd:p>An XHTML &lt;div&gt;.</xd:p>
        </xd:return>
    </xd:doc>
    <xsl:template name="attributesUsed" as="element(xh:div)">
        <xsl:variable name="allAttributes" select="$teiDocs/descendant-or-self::*/@*"/>
        <xsl:variable name="allAttributesNames" select="for $n in $allAttributes return local-name($n)"/>
        <xsl:variable name="distinctAttributes" select="distinct-values($allAttributesNames)" as="xs:string+"/>
        <div class="hidden">
            <h3 onclick="showHide(this)">Attributes used</h3>
            <table>
                <tbody>
                    <tr>
                        <td>Distinct attributes</td>
                        <td><xsl:value-of select="count($distinctAttributes)"/></td>
                    </tr>
                </tbody>
            </table>
            <table>
                <thead>
                    <tr>
                        <td>Attribute name</td>
                        <td>Number of times used</td>
                        <td>Number of distinct parent elements</td>
                        <td>Number of distinct attribute values</td>
                        <td>Number of documents containing this attribute</td>
                        <td>Average uses per document</td>
                        <td>TEI Guidelines</td>
                    </tr>
                </thead>
                <tbody>
                    <!--Create rows for each attribute-->
                    <xsl:for-each select="$distinctAttributes">
                        <xsl:sort order="ascending"/>
                        <xsl:variable name="thisAtt" select="."/>
                        
                        <!--Documents containing this attribute-->
                        <xsl:variable 
                            name="docs" 
                            select="$teiDocs[descendant-or-self::*[@*/local-name()=$thisAtt]]"/>
                        
                        <!--Each individual use of this attribute-->
                        <xsl:variable 
                            name="timesUsed" 
                            select="$teiDocs/descendant-or-self::*/@*[local-name()=$thisAtt]"/>
                        
                        <!--Distinct elements that contain this attribute-->
                        <xsl:variable 
                            name="distinctParentElements" 
                            select="distinct-values(for $n in $timesUsed return $n/parent::*/local-name())"/>
                        
                        <!--The distinct attribute values-->
                        <xsl:variable 
                            name="distinctValues" 
                            select="distinct-values(for $t in $timesUsed return tokenize(normalize-space($t),'\s+'))"/>
                        
                        <!--The count of all the above variables-->
                        <xsl:variable name="docsCount" select="count($docs)"/>
                        <xsl:variable name="timesUsedCount" select="count($timesUsed)"/>
                        <xsl:variable name="distinctParentElementsCount" select="count($distinctParentElements)"/>
                        <xsl:variable name="distinctValuesCount" select="count($distinctValues)"/>
                        
                        <!--fn:local-name() strips xml:id, xml:lang, xml:base, and xml:space of their prefix.
                            For ease of viewing, we re-affix the xml prefix if it was stripped from the attribute name. -->
                        <xsl:variable name="thisAttName"
                            select="
                            if ($thisAtt=('id','base','lang','space')) 
                            then concat('xml:',$thisAtt)
                            else $thisAtt"/>
                        
                        <!--Now create the table row-->
                        <tr>
                            <td><span class="xmlAttName"><xsl:value-of select="$thisAttName"/></span></td>
                            <td><xsl:value-of select="$timesUsedCount"/></td>
                            <td><xsl:value-of select="$distinctParentElementsCount"/></td>
                            <td><xsl:value-of select="$distinctValuesCount"/></td>
                            <td><xsl:value-of select="$docsCount"/></td>
                            <td><xsl:value-of select="format-number($timesUsedCount div $docsCount,'#.###')"/></td>
                            <td><a href="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/REF-ATTS.html#{$thisAtt}">TEI</a></td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </div>
    </xsl:template>
    
    
    
    <!--************** CONSISTENCY CHECKS ********************-->
    
    
    <xd:doc>
        <xd:desc>
            <xd:ref name="createDiagnosticsDiv" type="template"/>
            <xd:p>This template creates the XHTML5 div elements for the 
            diagnostics output.</xd:p>
        </xd:desc>
        <xd:param name="id">
            <xd:p>Gives a unique id to the div. If nothing is supplied,
            it generates an id.</xd:p>
        </xd:param>
        <xd:param name="title">
            <xd:p>This is the title and header for the div. Required.</xd:p>
        </xd:param>
        <xd:param name="explanation">
            <xd:p>A short, prose explanation of what each div contains.</xd:p>
        </xd:param>
        <xd:param name="results">
            <xd:p>The results of a consistency check (usually &lt;table&gt; or &lt;ul&gt;).</xd:p>
        </xd:param>
        <xd:param name="resultsCount">
            <xd:p>The count of the results of a check. Since the results can be 
            any container elements with any number of descendants, this count needs
            to be supplied as a parameter, not calculated within this template.</xd:p>
        </xd:param>
        <xd:return>
            <xd:p>An XHTML div element.</xd:p>
        </xd:return>
    </xd:doc>
    <xsl:template name="createDiagnosticsDiv" as="element(xh:div)">
        <xsl:param name="id"/>
        <xsl:param name="title"/>
        <xsl:param name="explanation"/>
        <xsl:param name="results" as="element()*"/>
        <xsl:param name="resultsCount" as="xs:integer"/>
<!--        REMINDER: @CLASS='SHOWING' TEMPORARILY;-->
        <div class="showing" data-count="{$resultsCount}" id="{$id}" data-title="{string-join($title,'')}">
            <h3 onclick="showHide(this)" class="{if ($resultsCount=0) then 'complete' else 'toDo'}"><xsl:copy-of select="$title"/> (<xsl:value-of select="$resultsCount"/>)</h3>
            <div id="{$id}Explanation">
                <h4>Explanation</h4>
                <div class="explanation">
                    <p><xsl:copy-of select="$explanation"/></p>
                </div>
            </div>
            <xsl:choose>
                <xsl:when test="$resultsCount gt 0">
                    <xsl:sequence select="$results"/>
                </xsl:when>
                <xsl:otherwise><p>None found.</p></xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="generateDiagnosticsChecks" type="template"/>
            <xd:p>template: generateDiagnosticsChecks</xd:p>
            <xd:p>This template generates the main body of the diagnostics document,
                calling all of the consistency checks. Templates called: <!--List as they come up; do we need to list them?-->
                <xd:ul>
                    <xd:li></xd:li>
                    <xd:li/>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="generateDiagnosticChecks">
        <div>
            <h2>Consistency Checks</h2>
            <xsl:call-template name="badInternalLinks"/>
            <xsl:call-template name="badXmlLangValues"/>
        </div>
    </xsl:template>

    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="badInternalLinks" type="template"/>
            <xd:p>template: badInternalLinks</xd:p>
            <xd:p>This template checks that all internal targets are pointing to a declared entity
                declared somewhere in the project.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="badInternalLinks" as="element(xh:div)">
        <xsl:variable name="output" as="element(xh:ul)*">
            <xsl:for-each select="$teiDocs[descendant::*[@*]]">
                <xsl:variable name="thisDoc" select="."/>
                <xsl:variable name="thisDocUri" select="document-uri(root(.))"/>
    <!--    We can't assume documents have ids on their root elements.        -->
                <!--<xsl:variable name="thisDocId" select="@xml:id"/>-->
                <xsl:variable name="thisDocFileName" select="hcmc:returnFileName(.)"/>
                <xsl:message>Checking <xsl:value-of select="$thisDocFileName"/> (<xsl:value-of
                        select="position()"/>/<xsl:value-of select="count($teiDocs[//@target])"
                    />)</xsl:message>
                <xsl:variable name="temp" as="element()">
                    <ul>
                        <xsl:for-each select="//@*[not(local-name(.) = $excludedAtts)]">
                            <xsl:variable name="thisAtt" select="."/>
                            <xsl:variable name="thisAttString" select="normalize-space($thisAtt)"
                                as="xs:string"/>
                            <xsl:variable name="thisAttTokens" select="tokenize($thisAttString, '\s+')"
                                as="xs:string+"/>
    
                            <!--<xsl:variable name="itemsFound">-->
                                
                                <xsl:for-each select="$thisAttTokens">
                                    <!-- Is it a private URI scheme? We use the regex from the TEI 
                                         definition of teidata.prefix. If it is one, resolve it 
                                         before continuing. -->
                                    <xsl:variable 
                                        name="thisToken" 
                                        select="if (matches(., '^[a-z][a-z0-9\+\.\-]*:[^/]+'))
                                        then hcmc:resolvePrefixDef(., root($thisDoc))
                                        else ." as="xs:string"/>
                                    
                                    <xsl:if test="hcmc:isLocalPointer($thisToken)">
                                        
                                        <!-- At this point we need to resolve private URI schemes. 
                                             Leave that aside for the moment. -->
                                        
            
                                        <!-- Filepaths are relative to the containing document, so all 
                                             filepaths need to be resolved in order to be checked. -->
                                        <xsl:variable name="targetDoc" select="
                                            if (matches($thisToken, '.+#'))
                                            then resolve-uri(substring-before($thisToken, '#'), $thisDocUri)
                                            else if (matches($thisToken, '^#'))
                                            then $thisDocUri else ''"/>
                                        
                                        <xsl:variable name="targetId" select="substring-after($thisToken, '#')"/>
                                        <xsl:variable name="fullTarget" select="concat($targetDoc, '#', $targetId)"/>
                
                                        <xsl:choose>
                                            <xsl:when test="$teiDocs//key('declaredIds', $fullTarget)">
                                                 <!--<xsl:message>Found id for <xsl:value-of select="."/></xsl:message>-->
                                            </xsl:when>
                                            <xsl:when test="doc-available($fullTarget)">
                                                <!--<xsl:message>Found document for target.</xsl:message>-->
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <li><span class="xmlAttName"><xsl:value-of select="local-name($thisAtt)"/></span>: 
                                                    <span class="xmlAttVal"><xsl:value-of select="."/></span>
                                                </li>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:if>
                                    
                                </xsl:for-each>
                            <!--</xsl:variable>-->
                           <!-- <xsl:if test="$itemsFound//*:li">
                                <ul>
                                    <xsl:sequence select="$itemsFound"/>
                                </ul>
                            </xsl:if>-->
                        </xsl:for-each>
                    </ul>
                </xsl:variable>
                
                <xsl:if test="$temp//*:li">
                    <ul>
                        <li><xsl:value-of select="$thisDocFileName"/>
                            <xsl:sequence select="$temp"/>
                        </li>
                    </ul>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
<!--        Now create the output div.-->
 <!--       <xsl:if test="$output//*:ul">-->
        <xsl:call-template name="createDiagnosticsDiv">
            <xsl:with-param name="id" select="'badInternalLinks'"/>
            <xsl:with-param name="explanation"
                select="'These are links in the project to entities within
                the projects that do not seem to exist.'"/>
            <xsl:with-param name="title" select="'Bad Internal Links'"/>
            <xsl:with-param name="results" select="$output"/>
            <xsl:with-param name="resultsCount"
                select="count($output//xh:li[ancestor::xh:li])"/>
        </xsl:call-template>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="badXmlLangValues" type="template"/>
            <xd:p>template: badXmlLangValues</xd:p>
            <xd:p>This template checks that all @xml:lang attributes have
            values which conform with the permitted values in the IANA
            Language Subtag Registry.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="badXmlLangValues" as="element(xh:div)">
        <xsl:variable name="output" as="element(xh:ul)*">
            <xsl:for-each select="$teiDocs[descendant::*[@xml:lang]]">
                <xsl:variable name="thisDoc" select="."/>
                <xsl:variable name="thisDocUri" select="document-uri(root(.))"/>
                <!--    We can't assume documents have ids on their root elements.        -->
                <!--<xsl:variable name="thisDocId" select="@xml:id"/>-->
                <xsl:variable name="thisDocFileName" select="hcmc:returnFileName(.)"/>
                <xsl:message>Checking <xsl:value-of select="$thisDocFileName"/> (<xsl:value-of
                    select="position()"/>/<xsl:value-of select="count($teiDocs[//@target])"
                    />)</xsl:message>
                <xsl:variable name="temp" as="element()">
                    <ul>
                        <xsl:for-each select="//@xml:lang">
                            <!--<xsl:message>Checking xml:lang value: <xsl:value-of select="."/></xsl:message>-->
                            <xsl:if test="not(matches(., $xmlLangRegex))">
                                <!--<xsl:message>Found bad xml:lang value: <xsl:value-of select="."/></xsl:message>-->
                                <li><span class="xmlAttName">xml:lang</span>: 
                                    <span class="xmlAttVal"><xsl:value-of select="."/></span>
                                </li>
                            </xsl:if>
                        </xsl:for-each>
                    </ul>
                </xsl:variable>
                <xsl:if test="$temp//*:li">
                    <ul>
                        <li><xsl:value-of select="$thisDocFileName"/>
                            <xsl:sequence select="$temp"/>
                        </li>
                    </ul>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>    
        <xsl:call-template name="createDiagnosticsDiv">
            <xsl:with-param name="id" select="'badXmlLangValues'"/>
            <xsl:with-param name="explanation"
                select="'These values for @xml:lang attributes do not 
                conform with those specified in the IANA Language Subtag
                Registry.'"/>
            <xsl:with-param name="title" select="'Bad @xml:lang Values'"/>
            <xsl:with-param name="results" select="$output"/>
            <xsl:with-param name="resultsCount"
                select="count($output//xh:li[ancestor::xh:li])"/>
        </xsl:call-template>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="hcmc:isLocalPointer" type="function"/>
            <xd:p>This function takes a string input and tries to determine
        whether it's the sort of internal reference link that we want to check.
        We do this because we cannot easily determine what kinds of attribute 
        values can or should contain pointers.</xd:p>
        </xd:desc>
        <xd:param name="token">
            <xd:p>A string input.</xd:p>
        </xd:param>
        <xd:return>
            <xd:p>A boolean value in reference to whether or not
            the string refers to a local pointer.</xd:p>
        </xd:return>
    </xd:doc>
    <xsl:function name="hcmc:isLocalPointer" as="xs:boolean">
        <xsl:param as="xs:string" name="token"/>
        <xsl:choose>
<!-- Exclude external schemes first. Crude but I think it should work.-->
            <xsl:when test="matches($token, '^[A-Za-z][A-Za-z\d\.\+\-]+://')">
                <xsl:value-of select="false()"/>
            </xsl:when>
<!-- Is it a direct link to a document? We assume that a document has
     an extension of up to six characters. -->
            <xsl:when test="matches($token, '[^\.]+\.[^\.]{1,6}$')">
                <xsl:value-of select="true()"/>
            </xsl:when>
<!-- Does it end with a hash followed by a QName? Regex is based on XML Schema
                XML Character Classes \i and \c. -->
            <xsl:when test="matches($token, '#\i\c*')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="hcmc:resolvePrefixDef" type="function"/>
            <xd:p>This function tries to look up a prefixDef by 
            prefix for the apparent prefix component of a pointer;
            if it finds a prefixDef, it does the replacement, but
            otherwise it returns the string unchanged.</xd:p>
        </xd:desc>
        <xd:param name="token">
            <xd:p>A referencing token with a private URI.</xd:p>
        </xd:param>
        <xd:return>
            <xd:p>If the private URI for the token can be resolved,
            then return the resolved token. Otherwise, do nothing
            to the token and return it.</xd:p>
        </xd:return>
    </xd:doc>
    <xsl:function name="hcmc:resolvePrefixDef" as="xs:string">
        <xsl:param name="token" as="xs:string"/>
        <xsl:param name="sourceDoc" as="document-node()"/>
        <xsl:variable name="prefix" select="substring-before($token, ':')"/>
<!--    Search for a prefixDef in the source document first, but if not found them look elsewhere.   -->
        <xsl:variable name="localPrefixDef" select="$sourceDoc/key('prefixDefs', $prefix)"/>
        <xsl:variable name="prefixDef" select="if ($localPrefixDef/@matchPattern) then $localPrefixDef else $teiDocs//key('prefixDefs', $prefix)"/>
        <xsl:choose>
            <xsl:when test="$prefixDef">
                <!--<xsl:message>prefixDef: <xsl:value-of select="concat($prefixDef[1]/@ident, ', ', $prefixDef[1]/@matchPattern, ', ', $prefixDef[1]/@replacementPattern)"/></xsl:message>-->
                <xsl:value-of select="replace(substring-after($token, ':'), $prefixDef[@matchPattern][1]/@matchPattern, $prefixDef[@matchPattern][1]/@replacementPattern)"/>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$token"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="hcmc:returnFileName" type="function"/>
            <xd:p>Takes in any node and returns the root file name
            without the path.</xd:p>
        </xd:desc>
        <xd:param name="node">
            <xd:p>Any node.</xd:p>
        </xd:param>
        <xd:return>
            <xd:p>The filename as a string.</xd:p>
        </xd:return>
    </xd:doc>
    <xsl:function name="hcmc:returnFileName" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:value-of select="normalize-space(tokenize(base-uri($node), '/')[last()])"/>
    </xsl:function>
    
    
<!--    HTML HEADER VARIABLES (TAKEN FROM THE MAP OF EARLY MODERN LONDON)-->
<!--    Joey to Martin: Should we have a globals module for these sorts of things?
        Martin to Joey: I think we should store these in external CSS and JS 
        files and pull them in with unparsed-text(). That will make it easier
        for people to modify them.
        Joey to Martin: Good call. I've commented out the CDATAs since they
        were breaking the Javascript in the output.
    
    -->
    
    <xd:doc>
        <xd:desc>
            <xd:ref name="javascript" type="variable"/>
            <xd:p>The javascript required for functionality on the diagnostics output.
            The content is editable by users in this directory: <xd:a href="script.js">script.js</xd:a>.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="javascript">
        <script type="text/javascript" xmlns="http://www.w3.org/1999/xhtml">
<!--            These CDATAs seem to break the javascript in the XHTML5 output.-->
          <!--<xsl:text>&lt;![CDATA[</xsl:text>-->
            <xsl:value-of select="unparsed-text('script.js')"/>
         <!-- <xsl:text>]]&gt;</xsl:text>-->
        </script>
    </xsl:variable>
    
<!-- We should store this externally and pull it in with unparsed-text().   -->
    <xd:doc>
        <xd:desc>
            <xd:ref name="css" type="variable"/>
            <xd:p>The CSS required for styling on the diagnostics output.
                The content is editable by users in this directory: <xd:a href="style.css">style.css</xd:a>.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="css">
        <style type="text/css" xmlns="http://www.w3.org/1999/xhtml">
          <xsl:comment>
            <xsl:value-of select="unparsed-text('style.css')"/>
          </xsl:comment>
        </style>
    </xsl:variable>


</xsl:stylesheet>
