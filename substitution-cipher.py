# cryptanalysis of substition ciphers
# go read: https://www.researchgate.net/publication/266714630_A_fast_method_for_cryptanalysis_of_substitution_ciphers
# use lower case ascii(26) letters. Whitespace will be ignored
# >500 words to be accurate

import numpy as np
from collections import Counter
import random as r

class solver:
  
  def __init__(self, c: str):
    # :c -> ciphertext
    self.c = c
    
    # ignore ' ' for now
    self.__ascii__ = 'abcdefghijklmnopqrstuvwxyz'
    # a-priori guess for decryption-key
    self.dkey = list()
    temp = [x[0] for x in Counter(c).most_common() if x[0] in self.__ascii__]
    for x in self.__ascii__:
      # absent keys in ciphertext get appended at last
      if x not in temp: temp.append(x)

    self.dkey = temp
    self.__common__map = dict()
    self.__common__str = str()
    self.__common__map.update( {'e': 0.1249, 't': 0.0928, 'a': 0.0804, 'o': 0.0764, 'i': 0.0757, 'n': 0.0723, 's': 0.0651, 'r': 0.0628, 'h': 0.0505, 'l': 0.0407, 'd': 0.0382, 'c': 0.0334, 'u': 0.0273, 'm': 0.0251, 'f': 0.024, 'p': 0.0214, 'g': 0.0187, 'w': 0.0168, 'y': 0.0166, 'b': 0.0148, 'v': 0.0105, 'k': 0.0054, 'x': 0.0023, 'j': 0.0016, 'q': 0.0012, 'z': 0.0009} )
    self.__common__str += ''.join(self.__common__map.keys())
    self.d_t = np.array([
        [0.378, 0.413, 0.688, 0.073, 0.183, 1.454, 1.339, 2.048, 0.026, 0.530, 1.168, 0.477, 0.031, 0.374, 0.163, 0.172, 0.120, 0.117, 0.144, 0.027, 0.255, 0.016, 0.214, 0.005, 0.057, 0.005],
        [1.205, 0.171, 0.530, 1.041, 1.343, 0.010, 0.337, 0.426, 3.556, 0.098, 0.001, 0.026, 0.255, 0.026, 0.006, 0.004, 0.002, 0.082, 0.227, 0.003, 0.001, 0.000, 0.000, 0.000, 0.000, 0.004],
        [0.012, 1.487, 0.003, 0.005, 0.316, 1.985, 0.871, 1.075, 0.014, 1.087, 0.368, 0.448, 0.119, 0.285, 0.074, 0.203, 0.205, 0.060, 0.217, 0.230, 0.205, 0.105, 0.019, 0.012, 0.002, 0.012],
        [0.039, 0.442, 0.057, 0.210, 0.088, 1.758, 0.290, 1.277, 0.021, 0.365, 0.195, 0.166, 0.870, 0.546, 1.175, 0.224, 0.094, 0.330, 0.036, 0.097, 0.178, 0.064, 0.019, 0.007, 0.001, 0.003],
        [0.385, 1.123, 0.286, 0.835, 0.023, 2.433, 1.128, 0.315, 0.002, 0.432, 0.296, 0.699, 0.017, 0.318, 0.203, 0.089, 0.255, 0.001, 0.000, 0.099, 0.288, 0.043, 0.022, 0.001, 0.011, 0.064],
        [0.692, 1.041, 0.347, 0.465, 0.339, 0.073, 0.509, 0.009, 0.011, 0.064, 1.352, 0.416, 0.079, 0.028, 0.067, 0.006, 0.953, 0.006, 0.098, 0.004, 0.052, 0.052, 0.003, 0.011, 0.006, 0.004],
        [0.932, 1.053, 0.218, 0.398, 0.550, 0.009, 0.405, 0.006, 0.315, 0.056, 0.005, 0.155, 0.311, 0.065, 0.017, 0.191, 0.002, 0.024, 0.057, 0.008, 0.001, 0.039, 0.000, 0.000, 0.007, 0.000],
        [1.854, 0.362, 0.686, 0.727, 0.728, 0.160, 0.397, 0.121, 0.015, 0.086, 0.189, 0.121, 0.128, 0.175, 0.032, 0.042, 0.100, 0.013, 0.248, 0.027, 0.069, 0.097, 0.001, 0.001, 0.001, 0.001],
        [3.075, 0.130, 0.926, 0.485, 0.763, 0.026, 0.015, 0.084, 0.001, 0.013, 0.003, 0.001, 0.074, 0.013, 0.002, 0.001, 0.000, 0.005, 0.050, 0.004, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000],
        [0.829, 0.124, 0.528, 0.387, 0.624, 0.006, 0.142, 0.010, 0.002, 0.577, 0.253, 0.012, 0.135, 0.023, 0.053, 0.019, 0.006, 0.013, 0.425, 0.007, 0.035, 0.020, 0.000, 0.000, 0.000, 0.000],
        [0.765, 0.003, 0.151, 0.188, 0.493, 0.008, 0.126, 0.085, 0.005, 0.032, 0.043, 0.003, 0.148, 0.018, 0.003, 0.002, 0.031, 0.008, 0.050, 0.003, 0.019, 0.000, 0.000, 0.005, 0.001, 0.000],
        [0.651, 0.461, 0.538, 0.794, 0.281, 0.001, 0.023, 0.149, 0.598, 0.149, 0.002, 0.083, 0.163, 0.003, 0.001, 0.001, 0.001, 0.000, 0.042, 0.001, 0.000, 0.118, 0.000, 0.000, 0.005, 0.001],
        [0.147, 0.405, 0.136, 0.011, 0.101, 0.394, 0.454, 0.543, 0.001, 0.346, 0.091, 0.188, 0.001, 0.138, 0.019, 0.136, 0.128, 0.000, 0.005, 0.089, 0.003, 0.005, 0.004, 0.001, 0.000, 0.002],
        [0.793, 0.001, 0.565, 0.337, 0.318, 0.009, 0.093, 0.003, 0.001, 0.005, 0.001, 0.004, 0.115, 0.096, 0.004, 0.239, 0.001, 0.001, 0.062, 0.090, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000],
        [0.237, 0.082, 0.164, 0.488, 0.285, 0.000, 0.006, 0.213, 0.000, 0.065, 0.000, 0.001, 0.096, 0.001, 0.146, 0.000, 0.001, 0.000, 0.009, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000],
        [0.478, 0.106, 0.324, 0.361, 0.123, 0.001, 0.055, 0.474, 0.094, 0.263, 0.001, 0.001, 0.105, 0.016, 0.001, 0.137, 0.000, 0.001, 0.012, 0.001, 0.000, 0.001, 0.000, 0.000, 0.000, 0.000],
        [0.385, 0.015, 0.148, 0.132, 0.152, 0.066, 0.051, 0.197, 0.228, 0.061, 0.003, 0.000, 0.086, 0.010, 0.001, 0.000, 0.025, 0.001, 0.026, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000],
        [0.361, 0.007, 0.385, 0.222, 0.374, 0.079, 0.035, 0.031, 0.379, 0.015, 0.004, 0.001, 0.001, 0.001, 0.002, 0.001, 0.000, 0.000, 0.002, 0.001, 0.000, 0.001, 0.000, 0.000, 0.000, 0.000],
        [0.093, 0.017, 0.016, 0.150, 0.029, 0.013, 0.097, 0.008, 0.001, 0.015, 0.007, 0.014, 0.001, 0.024, 0.001, 0.025, 0.003, 0.003, 0.000, 0.004, 0.000, 0.000, 0.000, 0.000, 0.000, 0.002],
        [0.576, 0.017, 0.146, 0.195, 0.107, 0.002, 0.046, 0.112, 0.001, 0.233, 0.002, 0.002, 0.185, 0.003, 0.000, 0.001, 0.000, 0.000, 0.176, 0.011, 0.004, 0.000, 0.000, 0.023, 0.000, 0.000],
        [0.825, 0.000, 0.140, 0.071, 0.270, 0.000, 0.001, 0.001, 0.000, 0.000, 0.000, 0.000, 0.002, 0.000, 0.000, 0.000, 0.000, 0.000, 0.005, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000],
        [0.214, 0.001, 0.017, 0.006, 0.098, 0.051, 0.048, 0.003, 0.003, 0.011, 0.001, 0.000, 0.003, 0.002, 0.002, 0.001, 0.003, 0.002, 0.006, 0.001, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000],
        [0.022, 0.047, 0.030, 0.003, 0.039, 0.000, 0.000, 0.000, 0.004, 0.001, 0.000, 0.026, 0.005, 0.000, 0.002, 0.067, 0.000, 0.000, 0.003, 0.000, 0.002, 0.000, 0.003, 0.000, 0.000, 0.000],
        [0.052, 0.000, 0.026, 0.054, 0.003, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.059, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000],
        [0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.148, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000],
        [0.050, 0.000, 0.025, 0.007, 0.012, 0.000, 0.000, 0.000, 0.001, 0.001, 0.000, 0.000, 0.002, 0.000, 0.000, 0.000, 0.000, 0.000, 0.002, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.003],
    ], dtype=np.float32)

    self.__random__index = list()
    for l, freq in self.__common__map.items():
      self.__random__index.extend([self.__common__str.index(l)] * int(freq * 1000))


  def __diagram_get(self, text: str):
    __diagram__ = np.full(shape=(26, 26), fill_value=0.0, dtype=np.float32)
    
    (text, count) = text.lower(), 0
    for i in range(len(text[1:])): #len(text)-1
      if text[i] in self.__ascii__ and text[i+1] in self.__ascii__:
        __diagram__[self.__common__str.index(text[i])][self.__common__str.index(text[i+1])] += 1
        count += 1
      else: continue

    __diagram__ *= 100
    __diagram__ /= count

    return __diagram__

  def distance_sum(self, e):
    return abs(self.d_t - e).sum()

  def random(self):
    # this is considerably faster 
    return r.sample(self.__random__index, 2)

  def swap(self, m, i1, i2):
    m[[i1, i2]] = m[[i2, i1]]
    m[:, [i1, i2]] = m[:, [i2, i1]]

  def plaintext(self, dkey):
    ind = [self.__common__str.index(temp) for temp in self.__common__str]
    lookup = dict()

    for a, b in zip(dkey, ind):
      lookup[a] = self.__common__str[b]
    
    res = ''
    for temp in self.c:
      res += lookup.get(temp.lower(), temp)
    
    return res

  def plain(self):
    # call SOLVE before calling plain
    return self.plaintext(self.dkey)

  def SOLVE(self):
    dkey = self.dkey[:]
    plaintext = self.plaintext(dkey)
    __diagram__ = self.__diagram_get(plaintext)

    __score__, __iter__ = self.distance_sum(__diagram__), 0

    n = 0
    while __iter__ < 5000:
      # until score has not improved for 5000 generations
      (a, b) = self.random()
      diagram = np.copy(__diagram__)
      self.swap(diagram, a, b)
      score = self.distance_sum(diagram)

      if score < __score__:
        __diagram__ = np.copy(diagram)
        (dkey[a], dkey[b]) = (dkey[b], dkey[a])
        __iter__ = 0 #set __iter__ 0 when score has improved
        __score__ = score
      else: __iter__ += 1
    
    self.dkey = dkey[:]

# -----------------------------------------------------------------------------------------------------
# test
# apparently there are standard texts in the net that can be tested on substitution cipher
# __ciphertext__numberofchars

__ciphertext__1000 = '''Tpg mdff bispdzi ap niob anoa up cdwowaib now ozzpxeoudic ani zpxxiuzixiua py ou iuaibebdwi mndzn tpg noji bivobcic mdan wgzn ijdf ypbilpcduvw. D obbdjic nibi tiwaibcot; ouc xt ydbwa aowr dw ap owwgbi xt ciob wdwaib py xt mifyobi, ouc duzbiowduv zpuydciuzi du ani wgzziww py xt gucibaorduv.

D ox ofbioct yob upban py Fpucpu; ouc ow D mofr du ani wabiiaw py Eiaibwlgbvn, D yiif o zpfc upbanibu lbiihi efot gepu xt zniirw, mndzn lboziw xt uibjiw, ouc ydffw xi mdan cifdvna. Cp tpg gucibwaouc andw yiifduv? Andw lbiihi, mndzn now abojiffic ybpx ani bivdpuw apmobcw mndzn D ox ocjouzduv, vdjiw xi o ypbiaowai py anpwi dzt zfdxiw. Duwedbdaic lt andw mduc py ebpxdwi, xt cot cbioxw lizpxi xpbi yibjiua ouc jdjdc. D abt du jodu ap li eibwgocic anoa ani epfi dw ani wioa py ybpwa ouc ciwpfoadpu; da ijib ebiwiuaw dawify ap xt dxovduoadpu ow ani bivdpu py liogat ouc cifdvna. Anibi, Xobvobia, ani wgu dw ypb ijib jdwdlfi; daw lbpoc cdwr sgwa wrdbaduv ani npbdhpu, ouc cdyygwduv o eibeiagof wefiucpgb. Anibi--'''

__ciphertext__9000 = '''Mlg yrhh qtjlrzt al otpq aopa el krupuatq opu pzzlncpertk aot zlnnteztntea ld pe teatqcqrut yorzo mlg opft qtwpqktk yrao ugzo tfrh dlqtilkrewu. R pqqrftk otqt mtuatqkpm; pek nm drqua apuv ru al puugqt nm ktpq uruatq ld nm ythdpqt, pek rezqtpurew zledrktezt re aot ugzztuu ld nm gektqapvrew.

R pn phqtpkm dpq elqao ld Hlekle; pek pu R yphv re aot uaqttau ld Ctatquigqwo, R dtth p zlhk elqaotqe iqttxt chpm gcle nm zottvu, yorzo iqpztu nm etqftu, pek drhhu nt yrao kthrwoa. Kl mlg gektquapek aoru dtthrew? Aoru iqttxt, yorzo opu aqpfthhtk dqln aot qtwrleu alypqku yorzo R pn pkfpezrew, wrftu nt p dlqtapuat ld aolut rzm zhrntu. Reucrqratk im aoru yrek ld cqlnrut, nm kpm kqtpnu itzlnt nlqt dtqftea pek frfrk. R aqm re fpre al it ctqugpktk aopa aot clht ru aot utpa ld dqlua pek ktulhparle; ra tftq cqtuteau rauthd al nm rnpwreparle pu aot qtwrle ld itpgam pek kthrwoa. Aotqt, Npqwpqta, aot uge ru dlq tftq fruriht; rau iqlpk kruv jgua uvrqarew aot olqrxle, pek krddgurew p ctqctagph uchteklgq. Aotqt--dlq yrao mlgq htpft, nm uruatq, R yrhh cga ulnt aqgua re cqtztkrew epfrwpalqu--aotqt uely pek dqlua pqt iperuotk; pek, uprhrew lftq p zphn utp, yt npm it ypdatk al p hpek ugqcpuurew re ylektqu pek re itpgam tftqm qtwrle oraotqal kruzlftqtk le aot opirapiht whlit. Rau cqlkgzarleu pek dtpagqtu npm it yraolga tbpncht, pu aot cotelntep ld aot otpftehm ilkrtu geklgiatkhm pqt re aolut gekruzlftqtk ulhragktu. Yopa npm ela it tbctzatk re p zlgeaqm ld tatqeph hrwoa? R npm aotqt kruzlftq aot ylekqlgu clytq yorzo paaqpzau aot ettkht; pek npm qtwghpat p aolgupek zthtuarph liutqfparleu, aopa qtsgrqt lehm aoru flmpwt al qtektq aotrq uttnrew tzzteaqrzrartu zleuruatea dlq tftq. R uophh uparpat nm pqktea zgqrluram yrao aot urwoa ld p cpqa ld aot ylqhk etftq itdlqt fruratk, pek npm aqtpk p hpek etftq itdlqt rncqreatk im aot dlla ld npe. Aotut pqt nm tearztnteau, pek aotm pqt ugddrzrtea al zlesgtq phh dtpq ld kpewtq lq ktpao, pek al rekgzt nt al zlnntezt aoru hpilqrlgu flmpwt yrao aot jlm p zorhk dtthu yote ot tnipqvu re p hraaht ilpa, yrao oru olhrkpm npatu, le pe tbctkrarle ld kruzlftqm gc oru eparft qrftq. Iga, ugcclurew phh aotut zlejtzagqtu al it dphut, mlg zpeela zleatua aot retuarnpiht itetdra yorzo R uophh zledtq le phh npevrek al aot hpua wtetqparle, im kruzlftqrew p cpuupwt etpq aot clht al aolut zlgeaqrtu, al qtpzo yorzo pa cqtutea ul npem nleaou pqt qtsgrurat; lq im puztqaprerew aot utzqta ld aot npweta, yorzo, rd pa phh cluuriht, zpe lehm it tddtzatk im pe gektqapvrew ugzo pu nret.

Aotut qtdhtzarleu opft kructhhtk aot pwraparle yrao yorzo R itwpe nm htaatq, pek R dtth nm otpqa whly yrao pe teaogurpun yorzo thtfpatu nt al otpfte; dlq elaorew zleaqrigatu ul ngzo al aqpesgrhhrut aot nrek pu p uatpkm cgqclut,--p clrea le yorzo aot ulgh npm drb rau reathhtzagph tmt. Aoru tbctkrarle opu itte aot dpflgqrat kqtpn ld nm tpqhm mtpqu. R opft qtpk yrao pqklgq aot pzzlgeau ld aot fpqrlgu flmpwtu yorzo opft itte npkt re aot cqluctza ld pqqrfrew pa aot Elqao Cpzrdrz Lztpe aoqlgwo aot utpu yorzo ugqqlgek aot clht. Mlg npm qtntnitq, aopa p orualqm ld phh aot flmpwtu npkt dlq cgqclutu ld kruzlftqm zlnclutk aot yolht ld lgq wllk gezht Aolnpu'u hriqpqm. Nm tkgzparle ypu etwhtzatk, mta R ypu cpuurlepathm dlek ld qtpkrew. Aotut flhgntu ytqt nm uagkm kpm pek erwoa, pek nm dpnrhrpqram yrao aotn rezqtputk aopa qtwqta yorzo R opk dtha, pu p zorhk, le htpqerew aopa nm dpaotq'u kmrew rejgezarle opk dlqirkkte nm gezht al phhly nt al tnipqv re p utpdpqrew hrdt.

Aotut frurleu dpktk yote R ctqgutk, dlq aot drqua arnt, aolut cltau yolut tddgurleu teaqpeztk nm ulgh, pek hrdatk ra al otpfte. R phul itzpnt p clta, pek dlq let mtpq hrftk re p Cpqpkrut ld nm lye zqtparle; R rnpwretk aopa R phul nrwoa liapre p erzot re aot atncht yotqt aot epntu ld Olntq pek Uopvuctpqt pqt zleutzqpatk. Mlg pqt ythh pzsgpreatk yrao nm dprhgqt, pek oly otpfrhm R ilqt aot krupcclreantea. Iga jgua pa aopa arnt R reotqratk aot dlqaget ld nm zlgure, pek nm aolgwoau ytqt agqetk real aot zopeeth ld aotrq tpqhrtq itea.

Urb mtpqu opft cpuutk urezt R qtulhftk le nm cqtutea gektqapvrew. R zpe, tfte ely, qtntnitq aot olgq dqln yorzo R ktkrzpatk nmuthd al aoru wqtpa teatqcqrut. R zlnnteztk im regqrew nm ilkm al opqkuorc. R pzzlncpertk aot yopht-druotqu le utftqph tbctkrarleu al aot Elqao Utp; R flhgeapqrhm tekgqtk zlhk, dpnret, aorqua, pek ypea ld uhttc; R ldate ylqvtk opqktq aope aot zlnnle uprhlqu kgqrew aot kpm, pek ktflatk nm erwoau al aot uagkm ld npaotnparzu, aot aotlqm ld ntkrzret, pek aolut iqpezotu ld comurzph uzrtezt dqln yorzo p epfph pkfteagqtq nrwoa ktqrft aot wqtpatua cqpzarzph pkfpeapwt. Ayrzt R pzagphhm orqtk nmuthd pu pe gektq-npat re p Wqttehpek yophtq, pek pzsgraatk nmuthd al pknrqparle. R ngua lye R dtha p hraaht cqlgk, yote nm zpcapre lddtqtk nt aot utzlek krweram re aot ftuuth, pek teaqtpatk nt al qtnpre yrao aot wqtpatua tpqetuaetuu; ul fphgpiht krk ot zleurktq nm utqfrztu.

Pek ely, ktpq Npqwpqta, kl R ela ktutqft al pzzlnchruo ulnt wqtpa cgqclut? Nm hrdt nrwoa opft itte cpuutk re tput pek hgbgqm; iga R cqtdtqqtk whlqm al tftqm tearztntea aopa ytphao chpztk re nm cpao. Lo, aopa ulnt tezlgqpwrew flrzt ylghk peuytq re aot pddrqnparft! Nm zlgqpwt pek nm qtulhgarle ru drqn; iga nm olctu dhgzagpat, pek nm ucrqrau pqt ldate ktcqtuutk. R pn pilga al cqlzttk le p hlew pek krddrzgha flmpwt, aot tntqwtezrtu ld yorzo yrhh ktnpek phh nm dlqaragkt: R pn qtsgrqtk ela lehm al qprut aot ucrqrau ld laotqu, iga ulntarntu al uguapre nm lye, yote aotrqu pqt dprhrew.

Aoru ru aot nlua dpflgqpiht ctqrlk dlq aqpfthhrew re Qguurp. Aotm dhm sgrzvhm lftq aot uely re aotrq uhtkwtu; aot nlarle ru chtpupea, pek, re nm lcrerle, dpq nlqt pwqttpiht aope aopa ld pe Tewhruo uapwt-zlpzo. Aot zlhk ru ela tbztuurft, rd mlg pqt yqpcctk re dgqu,--p kqtuu yorzo R opft phqtpkm pklcatk; dlq aotqt ru p wqtpa krddtqtezt itaytte yphvrew aot ktzv pek qtnprerew utpatk nlarlehtuu dlq olgqu, yote el tbtqzrut cqtfteau aot ihllk dqln pzagphhm dqttxrew re mlgq ftreu. R opft el pnirarle al hlut nm hrdt le aot clua-qlpk itaytte Ua. Ctatquigqwo pek Pqzopewth.

R uophh ktcpqa dlq aot hpaatq alye re p dlqaerwoa lq aoqtt yttvu; pek nm reatearle ru al orqt p uorc aotqt, yorzo zpe tpurhm it klet im cpmrew aot reugqpezt dlq aot lyetq, pek al tewpwt pu npem uprhlqu pu R aorev etztuupqm pnlew aolut yol pqt pzzgualntk al aot yopht-druorew. R kl ela reatek al uprh gearh aot nleao ld Jget; pek yote uophh R qtagqe? Po, ktpq uruatq, oly zpe R peuytq aoru sgtuarle? Rd R ugzzttk, npem, npem nleaou, ctqopcu mtpqu, yrhh cpuu itdlqt mlg pek R npm ntta. Rd R dprh, mlg yrhh utt nt pwpre ulle, lq etftq.

Dpqtythh, nm ktpq, tbzthhtea Npqwpqta. Otpfte uolytq klye ihtuurewu le mlg, pek upft nt, aopa R npm pwpre pek pwpre atuardm nm wqparagkt dlq phh mlgq hlft pek vreketuu.

--

Oly uhlyhm aot arnt cpuutu otqt, tezlncpuutk pu R pn im dqlua pek uely! mta p utzlek uatc ru apvte alypqku nm teatqcqrut. R opft orqtk p ftuuth, pek pn lzzgcrtk re zlhhtzarew nm uprhlqu; aolut yoln R opft phqtpkm tewpwtk, pcctpq al it nte '''

__plaintext__1000 = solver(__ciphertext__1000)
__plaintext__1000.SOLVE()
print(__plaintext__1000.plain())

__plaintext__9000 = solver(__ciphertext__9000)
__plaintext__9000.SOLVE()
print(__plaintext__9000.plain())
