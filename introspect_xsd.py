# -*- coding: utf-8 -*-
"""Print the direct child structure of given elements from uVision's XSD."""
from lxml import etree

XSD = r"C:\Keil_v5\UV4\project_projx.xsd"
XS = "{http://www.w3.org/2001/XMLSchema}"
root = etree.parse(XSD).getroot()


def decl(name):
    for el in root.iter(XS + "element"):
        if el.get("name") == name:
            return el
    return None


def show(name, depth=1, ind=0, path=""):
    el = decl(name)
    if el is None:
        print("  " * ind + f"!! no decl for {name}")
        return
    ct = el.find(XS + "complexType")
    if ct is None:
        print("  " * ind + f"{name} (no complexType)")
        return
    for container in (XS + "sequence", XS + "choice", XS + "all"):
        seq = ct.find(container)
        if seq is not None:
            break
    else:
        print("  " * ind + f"{name} (no sequence/choice)")
        return
    for ch in seq:
        if not isinstance(ch.tag, str):
            continue
        tag = etree.QName(ch).localname
        if tag == "element":
            nm = ch.get("name") or ch.get("ref")
            if nm is None:
                continue
            mn = ch.get("minOccurs", "1")
            flag = "" if mn == "1" else f"  [min={mn}]"
            print("  " * ind + f"- {nm}{flag}")
            if depth > 0:
                if ch.get("ref"):
                    show(ch.get("ref"), depth - 1, ind + 1)
                elif ch.get("name"):
                    show(ch.get("name"), depth - 1, ind + 1)
        elif tag in ("sequence", "choice", "all"):
            print("  " * ind + f"- <{tag}>")
            for c2 in ch:
                nm = c2.get("name") or c2.get("ref")
                print("  " * (ind + 1) + f"- {nm}")


for nm in ["TargetDlls", "Driver"]:
    print("=" * 70)
    show(nm, depth=0)
