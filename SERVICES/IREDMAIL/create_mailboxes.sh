#!/bin/bash

DOMAIN="ecotech.tssr"
PASSWORD_HASH='$2b$12$KQWWF5mJMwJtzTRtWMXlJucL3OAkI/PHn916BGrsFAoVZwMJnG4ta'
DB_USER="vmailadmin"
DB_PASS="swRnasr2kqxRU1HRCt0GD0pIQn4aA3It"
DB_NAME="vmail"

USERS=(
am.boussaid br.el-mahdi el.costa in.benzema is.saidi lu.da lu.oliveira na.rahmani
ra.hamrouni ta.boucenna bo.garcia cl.dupont fe.nguyen os.rossi gr.kobayashi me.zhou
ni.dobrev ra.farouk te.schneider el.rahimi na.kowalski om.schneider sa.hernandez
al.al-khalil ca.vasquez fa.kowalski he.azzouz is.fontaine iv.schmidt lu.romano
pa.weber ra.sousa ta.ben ya.chettouh za.andersen am.gomez wa.ibrahimovic ya.ben
ai.rahman ca.ivanov fa.gonzalez ke.yamamoto la.bakir le.petrov ma.el-ghazali
ra.ben am.mendoza an.morel ar.carvalho ay.ishikawa ch.fischer el.lemoine is.rahmani
kh.bakir le.karam mi.lopez mi.petrov na.ivanov ni.rajavi ou.yamamoto sa.abe
sa.mohamed te.patel wa.ndiaye ad.farid al.ali al.amrane an.garcia ay.papadopoulos
bi.hassan ce.benguigui ch.rodriguez cl.ziani di.abdeslam el.habibi fa.dias fa.sato
fa.schmitt gr.lam he.ziani hi.meunier in.singh ke.zerouali ke.patel ke.rahman
kh.andersson la.el-ghazali le.velasquez li.nakamura li.matsuda li.bouziane
ma.dahl ma.benitez me.ferreira me.nguyen mi.touati mi.matsuda mi.boukhris
na.marquez na.matsuda ni.matsuda no.svensson om.ochoa om.touati ou.correia
ou.ziani ra.moreno ra.o-connor ra.kowalski sa.hamadi sa.rajavi so.amrani
te.yamashita te.romano to.berisha to.wang wa.fernandez ya.bianchi ya.belmokhtar
ya.habib ya.vega za.gonzalez za.dahl za.slimani ad.habibi bi.amrani la.klein
mi.larsen za.gomez ah.torres am.habibi bi.guedj ka.hamzaoui ke.mendoza li.prado
mi.novak na.larsen na.fuentes lu.zimmermann ma.subramanian ni.papadopoulos
no.ramos za.fernandez hu.dimitrov ad.bakir am.levi em.rizzo is.ishikawa le.tanaka
ha.rahman ja.liu ka.sato ka.benzema ka.farouk le.zhou pr.dobrev so.moreno za.ben
ad.abbassi ch.dupuis ho.benali la.benzema sa.popescu ta.sow el.morales ni.takeda
an.moretti ma.belhadj sa.bianchi ka.novak ri.nakamura so.kimura fa.ben gr.petrov
is.lemoine mo.rahmani ya.tsai yu.kobayashi ak.fischer al.fischer am.silva
bi.mendoza da.kim mo.mohamed no.abe ch.sato el.andersen da.ivanov ik.yilmaz
mi.pereira ta.costa ta.karam li.rodriguez da.johansson ti.demir al.gonzalez
gi.hassania ho.carvalho id.cherif li.singh ni.schaefer ra.meier sa.al-khalil
ar.vega ch.ramos fo.bensalem gi.klein ja.mekki ma.santiago se.boukhalfa
so.lombardi he.pereira im.rashid ka.levi ma.martinez na.touil ol.dimitrova
sa.rahman so.jaziri wa.qureshi ay.orozco da.varela sa.kumar va.hernandez
amir.gomez ay.ochoa en.morin la.wong yo.berisha ed.dante
)

for user in "${USERS[@]}"; do
    EMAIL="${user}@${DOMAIN}"
    mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "
    INSERT IGNORE INTO mailbox (username, password, name, storagebasedirectory, storagenode, maildir, quota, domain, active, created)
    VALUES ('${EMAIL}', '${PASSWORD_HASH}', '${user}', '/var/vmail', 'vmail', '${DOMAIN}/${user}/', 1024, '${DOMAIN}', 1, NOW());
    " 2>/dev/null
    echo "Créé : $EMAIL"
done

echo "Terminé."
