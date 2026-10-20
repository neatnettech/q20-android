
runtime/qnx-shims/qconnDoor.bin:     file format elf32-littlearm


Disassembly of section .text:

000021fc <main@@Base>:
    21fc:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
    2200:	b0bf      	sub	sp, #252	; 0xfc
    2202:	4c9c      	ldr	r4, [pc, #624]	; (2474 <main@@Base+0x278>)
    2204:	af3b      	add	r7, sp, #236	; 0xec
    2206:	4b9c      	ldr	r3, [pc, #624]	; (2478 <main@@Base+0x27c>)
    2208:	4681      	mov	r9, r0
    220a:	447c      	add	r4, pc
    220c:	4638      	mov	r0, r7
    220e:	4688      	mov	r8, r1
    2210:	2500      	movs	r5, #0
    2212:	58e6      	ldr	r6, [r4, r3]
    2214:	f8df a264 	ldr.w	sl, [pc, #612]	; 247c <main@@Base+0x280>
    2218:	6833      	ldr	r3, [r6, #0]
    221a:	46b3      	mov	fp, r6
    221c:	44fa      	add	sl, pc
    221e:	933d      	str	r3, [sp, #244]	; 0xf4
    2220:	f7ff ef24 	blx	206c <sigemptyset@plt>
    2224:	4638      	mov	r0, r7
    2226:	210f      	movs	r1, #15
    2228:	f7ff ee7e 	blx	1f28 <sigaddset@plt>
    222c:	4638      	mov	r0, r7
    222e:	210b      	movs	r1, #11
    2230:	f7ff ee7a 	blx	1f28 <sigaddset@plt>
    2234:	4638      	mov	r0, r7
    2236:	210a      	movs	r1, #10
    2238:	f7ff ee76 	blx	1f28 <sigaddset@plt>
    223c:	e897 0003 	ldmia.w	r7, {r0, r1}
    2240:	ab39      	add	r3, sp, #228	; 0xe4
    2242:	af3e      	add	r7, sp, #248	; 0xf8
    2244:	462a      	mov	r2, r5
    2246:	9538      	str	r5, [sp, #224]	; 0xe0
    2248:	e883 0003 	stmia.w	r3, {r0, r1}
    224c:	200f      	movs	r0, #15
    224e:	4b8c      	ldr	r3, [pc, #560]	; (2480 <main@@Base+0x284>)
    2250:	447b      	add	r3, pc
    2252:	f847 3d1c 	str.w	r3, [r7, #-28]!
    2256:	4639      	mov	r1, r7
    2258:	f7ff edc4 	blx	1de4 <sigaction@plt>
    225c:	4639      	mov	r1, r7
    225e:	462a      	mov	r2, r5
    2260:	200b      	movs	r0, #11
    2262:	f7ff edc0 	blx	1de4 <sigaction@plt>
    2266:	4639      	mov	r1, r7
    2268:	462a      	mov	r2, r5
    226a:	200a      	movs	r0, #10
    226c:	f7ff edba 	blx	1de4 <sigaction@plt>
    2270:	4f84      	ldr	r7, [pc, #528]	; (2484 <main@@Base+0x288>)
    2272:	2101      	movs	r1, #1
    2274:	2012      	movs	r0, #18
    2276:	f7ff ef56 	blx	2124 <signal@plt>
    227a:	200d      	movs	r0, #13
    227c:	2101      	movs	r1, #1
    227e:	447f      	add	r7, pc
    2280:	f7ff ef50 	blx	2124 <signal@plt>
    2284:	e00c      	b.n	22a0 <main@@Base+0xa4>
    2286:	2e55      	cmp	r6, #85	; 0x55
    2288:	d103      	bne.n	2292 <main@@Base+0x96>
    228a:	4b7f      	ldr	r3, [pc, #508]	; (2488 <main@@Base+0x28c>)
    228c:	58e3      	ldr	r3, [r4, r3]
    228e:	681d      	ldr	r5, [r3, #0]
    2290:	e006      	b.n	22a0 <main@@Base+0xa4>
    2292:	4b7e      	ldr	r3, [pc, #504]	; (248c <main@@Base+0x290>)
    2294:	2002      	movs	r0, #2
    2296:	4651      	mov	r1, sl
    2298:	58e3      	ldr	r3, [r4, r3]
    229a:	681a      	ldr	r2, [r3, #0]
    229c:	f001 ff54 	bl	4148 <main@@Base+0x1f4c>
    22a0:	4648      	mov	r0, r9
    22a2:	4641      	mov	r1, r8
    22a4:	463a      	mov	r2, r7
    22a6:	f7ff ef0c 	blx	20c0 <getopt@plt>
    22aa:	4606      	mov	r6, r0
    22ac:	3001      	adds	r0, #1
    22ae:	d1ea      	bne.n	2286 <main@@Base+0x8a>
    22b0:	4b6a      	ldr	r3, [pc, #424]	; (245c <main@@Base+0x260>)
    22b2:	2200      	movs	r2, #0
    22b4:	f04f 30ff 	mov.w	r0, #4294967295	; 0xffffffff
    22b8:	f04f 31ff 	mov.w	r1, #4294967295	; 0xffffffff
    22bc:	e9cd 0100 	strd	r0, r1, [sp]
    22c0:	2000      	movs	r0, #0
    22c2:	9302      	str	r3, [sp, #8]
    22c4:	2300      	movs	r3, #0
    22c6:	e9cd 2304 	strd	r2, r3, [sp, #16]
    22ca:	2100      	movs	r1, #0
    22cc:	e9cd 2306 	strd	r2, r3, [sp, #24]
    22d0:	2264      	movs	r2, #100	; 0x64
    22d2:	4b63      	ldr	r3, [pc, #396]	; (2460 <main@@Base+0x264>)
    22d4:	e9cd 010a 	strd	r0, r1, [sp, #40]	; 0x28
    22d8:	e9cd 010c 	strd	r0, r1, [sp, #48]	; 0x30
    22dc:	2026      	movs	r0, #38	; 0x26
    22de:	9308      	str	r3, [sp, #32]
    22e0:	3301      	adds	r3, #1
    22e2:	930e      	str	r3, [sp, #56]	; 0x38
    22e4:	2100      	movs	r1, #0
    22e6:	9314      	str	r3, [sp, #80]	; 0x50
    22e8:	2300      	movs	r3, #0
    22ea:	e9cd 2316 	strd	r2, r3, [sp, #88]	; 0x58
    22ee:	e9cd 2318 	strd	r2, r3, [sp, #96]	; 0x60
    22f2:	f44f 6296 	mov.w	r2, #1200	; 0x4b0
    22f6:	4b5b      	ldr	r3, [pc, #364]	; (2464 <main@@Base+0x268>)
    22f8:	e9cd 0110 	strd	r0, r1, [sp, #64]	; 0x40
    22fc:	e9cd 0112 	strd	r0, r1, [sp, #72]	; 0x48
    2300:	931a      	str	r3, [sp, #104]	; 0x68
    2302:	9320      	str	r3, [sp, #128]	; 0x80
    2304:	9326      	str	r3, [sp, #152]	; 0x98
    2306:	932c      	str	r3, [sp, #176]	; 0xb0
    2308:	2300      	movs	r3, #0
    230a:	e9cd 232e 	strd	r2, r3, [sp, #184]	; 0xb8
    230e:	e9cd 2330 	strd	r2, r3, [sp, #192]	; 0xc0
    2312:	f44f 5280 	mov.w	r2, #4096	; 0x1000
    2316:	4b54      	ldr	r3, [pc, #336]	; (2468 <main@@Base+0x26c>)
    2318:	e9cd 011c 	strd	r0, r1, [sp, #112]	; 0x70
    231c:	e9cd 011e 	strd	r0, r1, [sp, #120]	; 0x78
    2320:	2064      	movs	r0, #100	; 0x64
    2322:	9332      	str	r3, [sp, #200]	; 0xc8
    2324:	2100      	movs	r1, #0
    2326:	4b51      	ldr	r3, [pc, #324]	; (246c <main@@Base+0x270>)
    2328:	e9cd 0122 	strd	r0, r1, [sp, #136]	; 0x88
    232c:	e9cd 0124 	strd	r0, r1, [sp, #144]	; 0x90
    2330:	f44f 7061 	mov.w	r0, #900	; 0x384
    2334:	2100      	movs	r1, #0
    2336:	9333      	str	r3, [sp, #204]	; 0xcc
    2338:	e9cd 0128 	strd	r0, r1, [sp, #160]	; 0xa0
    233c:	f64f 73ff 	movw	r3, #65535	; 0xffff
    2340:	f240 30e9 	movw	r0, #1001	; 0x3e9
    2344:	2100      	movs	r1, #0
    2346:	9334      	str	r3, [sp, #208]	; 0xd0
    2348:	2300      	movs	r3, #0
    234a:	e9cd 012a 	strd	r0, r1, [sp, #168]	; 0xa8
    234e:	2000      	movs	r0, #0
    2350:	4947      	ldr	r1, [pc, #284]	; (2470 <main@@Base+0x274>)
    2352:	f7ff edfc 	blx	1f4c <procmgr_ability@plt>
    2356:	4607      	mov	r7, r0
    2358:	b128      	cbz	r0, 2366 <main@@Base+0x16a>
    235a:	494d      	ldr	r1, [pc, #308]	; (2490 <main@@Base+0x294>)
    235c:	2002      	movs	r0, #2
    235e:	4479      	add	r1, pc
    2360:	f001 fef2 	bl	4148 <main@@Base+0x1f4c>
    2364:	e06e      	b.n	2444 <main@@Base+0x248>
    2366:	4b4b      	ldr	r3, [pc, #300]	; (2494 <main@@Base+0x298>)
    2368:	58e4      	ldr	r4, [r4, r3]
    236a:	4620      	mov	r0, r4
    236c:	f000 fa2a 	bl	27c4 <main@@Base+0x5c8>
    2370:	60a6      	str	r6, [r4, #8]
    2372:	f241 1067 	movw	r0, #4455	; 0x1167
    2376:	60e0      	str	r0, [r4, #12]
    2378:	f001 fa1a 	bl	37b0 <main@@Base+0x15b4>
    237c:	4626      	mov	r6, r4
    237e:	4639      	mov	r1, r7
    2380:	f846 0b14 	str.w	r0, [r6], #20
    2384:	2001      	movs	r0, #1
    2386:	f000 fd2d 	bl	2de4 <main@@Base+0xbe8>
    238a:	4630      	mov	r0, r6
    238c:	f7ff ed1c 	blx	1dc8 <InitEncryptionChallenge@plt>
    2390:	b128      	cbz	r0, 239e <main@@Base+0x1a2>
    2392:	4941      	ldr	r1, [pc, #260]	; (2498 <main@@Base+0x29c>)
    2394:	2002      	movs	r0, #2
    2396:	4479      	add	r1, pc
    2398:	f001 fed6 	bl	4148 <main@@Base+0x1f4c>
    239c:	e04b      	b.n	2436 <main@@Base+0x23a>
    239e:	6823      	ldr	r3, [r4, #0]
    23a0:	2b00      	cmp	r3, #0
    23a2:	db05      	blt.n	23b0 <main@@Base+0x1b4>
    23a4:	493d      	ldr	r1, [pc, #244]	; (249c <main@@Base+0x2a0>)
    23a6:	2005      	movs	r0, #5
    23a8:	68e2      	ldr	r2, [r4, #12]
    23aa:	4479      	add	r1, pc
    23ac:	f001 fecc 	bl	4148 <main@@Base+0x1f4c>
    23b0:	b35d      	cbz	r5, 240a <main@@Base+0x20e>
    23b2:	4628      	mov	r0, r5
    23b4:	f002 fdee 	bl	4f94 <main@@Base+0x2d98>
    23b8:	b338      	cbz	r0, 240a <main@@Base+0x20e>
    23ba:	4939      	ldr	r1, [pc, #228]	; (24a0 <main@@Base+0x2a4>)
    23bc:	2002      	movs	r0, #2
    23be:	462a      	mov	r2, r5
    23c0:	4479      	add	r1, pc
    23c2:	f001 fec1 	bl	4148 <main@@Base+0x1f4c>
    23c6:	e036      	b.n	2436 <main@@Base+0x23a>
    23c8:	6863      	ldr	r3, [r4, #4]
    23ca:	b12b      	cbz	r3, 23d8 <main@@Base+0x1dc>
    23cc:	4620      	mov	r0, r4
    23ce:	f000 ffa5 	bl	331c <main@@Base+0x1120>
    23d2:	2800      	cmp	r0, #0
    23d4:	da1f      	bge.n	2416 <main@@Base+0x21a>
    23d6:	e014      	b.n	2402 <main@@Base+0x206>
    23d8:	2501      	movs	r5, #1
    23da:	f8a4 8040 	strh.w	r8, [r4, #64]	; 0x40
    23de:	f8a4 7042 	strh.w	r7, [r4, #66]	; 0x42
    23e2:	4620      	mov	r0, r4
    23e4:	f884 5044 	strb.w	r5, [r4, #68]	; 0x44
    23e8:	f001 fd8a 	bl	3f00 <main@@Base+0x1d04>
    23ec:	68a3      	ldr	r3, [r4, #8]
    23ee:	2b00      	cmp	r3, #0
    23f0:	dd07      	ble.n	2402 <main@@Base+0x206>
    23f2:	2005      	movs	r0, #5
    23f4:	4631      	mov	r1, r6
    23f6:	f001 fea7 	bl	4148 <main@@Base+0x1f4c>
    23fa:	2302      	movs	r3, #2
    23fc:	6065      	str	r5, [r4, #4]
    23fe:	6123      	str	r3, [r4, #16]
    2400:	e009      	b.n	2416 <main@@Base+0x21a>
    2402:	4620      	mov	r0, r4
    2404:	f000 ff52 	bl	32ac <main@@Base+0x10b0>
    2408:	e005      	b.n	2416 <main@@Base+0x21a>
    240a:	4e26      	ldr	r6, [pc, #152]	; (24a4 <main@@Base+0x2a8>)
    240c:	f04f 0803 	mov.w	r8, #3
    2410:	f248 3776 	movw	r7, #33654	; 0x8376
    2414:	447e      	add	r6, pc
    2416:	6823      	ldr	r3, [r4, #0]
    2418:	2b00      	cmp	r3, #0
    241a:	dad5      	bge.n	23c8 <main@@Base+0x1cc>
    241c:	f7ff ebf8 	blx	1c10 <__get_errno_ptr@plt>
    2420:	68e5      	ldr	r5, [r4, #12]
    2422:	6800      	ldr	r0, [r0, #0]
    2424:	f7ff ebfa 	blx	1c1c <strerror@plt>
    2428:	491f      	ldr	r1, [pc, #124]	; (24a8 <main@@Base+0x2ac>)
    242a:	462a      	mov	r2, r5
    242c:	4479      	add	r1, pc
    242e:	4603      	mov	r3, r0
    2430:	2002      	movs	r0, #2
    2432:	f001 fe89 	bl	4148 <main@@Base+0x1f4c>
    2436:	4620      	mov	r0, r4
    2438:	f000 fca2 	bl	2d80 <main@@Base+0xb84>
    243c:	f104 0014 	add.w	r0, r4, #20
    2440:	f7ff ee0e 	blx	2060 <DisposeEncryptionChallenge@plt>
    2444:	9a3d      	ldr	r2, [sp, #244]	; 0xf4
    2446:	2001      	movs	r0, #1
    2448:	f8db 3000 	ldr.w	r3, [fp]
    244c:	429a      	cmp	r2, r3
    244e:	d001      	beq.n	2454 <main@@Base+0x258>
    2450:	f7ff ec84 	blx	1d5c <__stack_chk_fail@plt>
    2454:	b03f      	add	sp, #252	; 0xfc
    2456:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
    245a:	bf00      	nop
    245c:	0000      	movs	r0, r0
    245e:	2006      	movs	r0, #6
    2460:	0001      	movs	r1, r0
    2462:	2006      	movs	r0, #6
    2464:	0003      	movs	r3, r0
    2466:	2006      	movs	r0, #6
    2468:	0024      	movs	r4, r4
    246a:	2002      	movs	r0, #2
    246c:	0017      	movs	r7, r2
    246e:	2009      	movs	r0, #9
    2470:	0027      	movs	r7, r4
    2472:	204e      	movs	r0, #78	; 0x4e
    2474:	6df2      	ldr	r2, [r6, #92]	; 0x5c
    2476:	0000      	movs	r0, r0
    2478:	0258      	lsls	r0, r3, #9
    247a:	0000      	movs	r0, r0
    247c:	3c21      	subs	r4, #33	; 0x21
    247e:	0000      	movs	r0, r0
    2480:	1083      	asrs	r3, r0, #2
    2482:	0000      	movs	r0, r0
    2484:	3bd3      	subs	r3, #211	; 0xd3
    2486:	0000      	movs	r0, r0
    2488:	027c      	lsls	r4, r7, #9
    248a:	0000      	movs	r0, r0
    248c:	0260      	lsls	r0, r4, #9
    248e:	0000      	movs	r0, r0
    2490:	3af6      	subs	r2, #246	; 0xf6
    2492:	0000      	movs	r0, r0
    2494:	0244      	lsls	r4, r0, #9
    2496:	0000      	movs	r0, r0
    2498:	3ae2      	subs	r2, #226	; 0xe2
    249a:	0000      	movs	r0, r0
    249c:	3af8      	subs	r2, #248	; 0xf8
    249e:	0000      	movs	r0, r0
    24a0:	3b02      	subs	r3, #2
    24a2:	0000      	movs	r0, r0
    24a4:	3acc      	subs	r2, #204	; 0xcc
    24a6:	0000      	movs	r0, r0
    24a8:	3ad3      	subs	r2, #211	; 0xd3
    24aa:	0000      	movs	r0, r0
    24ac:	4000      	ands	r0, r0
    24ae:	e1a0      	b.n	27f2 <main@@Base+0x5f6>
    24b0:	0000      	movs	r0, r0
    24b2:	e59d      	b.n	1ff0 <time@plt+0x4>
    24b4:	1004      	asrs	r4, r0, #32
    24b6:	e28d      	b.n	29d4 <main@@Base+0x7d8>
    24b8:	2100      	movs	r1, #0
    24ba:	e081      	b.n	25c0 <main@@Base+0x3c4>
    24bc:	2004      	movs	r0, #4
    24be:	e282      	b.n	29c6 <main@@Base+0x7ca>
    24c0:	3002      	adds	r0, #2
    24c2:	e1a0      	b.n	2806 <main@@Base+0x60a>
    24c4:	c004      	stmia	r0!, {r2}
    24c6:	e493      	b.n	1df0 <hu_SHA512End@plt>
    24c8:	0000      	movs	r0, r0
    24ca:	e33c      	b.n	2b46 <main@@Base+0x94a>
    24cc:	fffc 1aff 			; <UNDEFINED> instruction: 0xfffc1aff
    24d0:	4004      	ands	r4, r0
    24d2:	e52d      	b.n	1f30 <sigaddset@plt+0x8>
    24d4:	4000      	ands	r0, r0
    24d6:	e1a0      	b.n	281a <main@@Base+0x61e>
    24d8:	5001      	str	r1, [r0, r0]
    24da:	e1a0      	b.n	281e <main@@Base+0x622>
    24dc:	6002      	str	r2, [r0, #0]
    24de:	e1a0      	b.n	2822 <main@@Base+0x626>
    24e0:	fe11 ebff 	mrc2	11, 0, lr, cr1, cr15, {7}	; <UNPREDICTABLE>
    24e4:	d004      	beq.n	24f0 <main@@Base+0x2f4>
    24e6:	e28d      	b.n	2a04 <main@@Base+0x808>
    24e8:	7064      	strb	r4, [r4, #1]
    24ea:	e59f      	b.n	202c <strdup@plt+0x8>
    24ec:	7007      	strb	r7, [r0, #0]
    24ee:	e08f      	b.n	2610 <main@@Base+0x414>
    24f0:	0060      	lsls	r0, r4, #1
    24f2:	e59f      	b.n	2034 <GetEncryptionChallengeEx@plt+0x4>
    24f4:	0000      	movs	r0, r0
    24f6:	e797      	b.n	2428 <main@@Base+0x22c>
    24f8:	105c      	asrs	r4, r3, #1
    24fa:	e59f      	b.n	203c <inet_ntop@plt>
    24fc:	1001      	asrs	r1, r0, #32
    24fe:	e797      	b.n	2430 <main@@Base+0x234>
    2500:	feaf ebff 	mcr2	11, 5, lr, cr15, cr15, {7}	; <UNPREDICTABLE>
    2504:	0054      	lsls	r4, r2, #1
    2506:	e59f      	b.n	2048 <fchmod@plt>
    2508:	0000      	movs	r0, r0
    250a:	e797      	b.n	243c <main@@Base+0x240>
    250c:	1050      	asrs	r0, r2, #1
    250e:	e59f      	b.n	2050 <fchmod@plt+0x8>
    2510:	1001      	asrs	r1, r0, #32
    2512:	e797      	b.n	2444 <main@@Base+0x248>
    2514:	fe47 ebff 	mcr2	11, 2, lr, cr7, cr15, {7}	; <UNPREDICTABLE>
    2518:	0048      	lsls	r0, r1, #1
    251a:	e59f      	b.n	205c <__aeabi_uidivmod@plt+0x8>
    251c:	0000      	movs	r0, r0
    251e:	e797      	b.n	2450 <main@@Base+0x254>
    2520:	1044      	asrs	r4, r0, #1
    2522:	e59f      	b.n	2064 <DisposeEncryptionChallenge@plt+0x4>
    2524:	1001      	asrs	r1, r0, #32
    2526:	e797      	b.n	2458 <main@@Base+0x25c>
    2528:	fe23 ebff 	mcr2	11, 1, lr, cr3, cr15, {7}	; <UNPREDICTABLE>
    252c:	003c      	movs	r4, r7
    252e:	e59f      	b.n	2070 <sigemptyset@plt+0x4>
    2530:	7000      	strb	r0, [r0, #0]
    2532:	e797      	b.n	2464 <main@@Base+0x268>
    2534:	1000      	asrs	r0, r0, #32
    2536:	e3a0      	b.n	2c7a <main@@Base+0xa7e>
    2538:	1000      	asrs	r0, r0, #32
    253a:	e587      	b.n	204c <fchmod@plt+0x4>
    253c:	0004      	movs	r4, r0
    253e:	e1a0      	b.n	2882 <main@@Base+0x686>
    2540:	1005      	asrs	r5, r0, #32
    2542:	e1a0      	b.n	2886 <main@@Base+0x68a>
    2544:	2006      	movs	r0, #6
    2546:	e1a0      	b.n	288a <main@@Base+0x68e>
    2548:	ff2b faff 	vpmin.u32	<illegal reg q7.5>, <illegal reg q13.5>, <illegal reg q15.5>
    254c:	fd7b ebff 	ldc2l	11, cr14, [fp, #-1020]!	; 0xfffffc04	; <UNPREDICTABLE>
    2550:	fffe eaff 			; <UNDEFINED> instruction: 0xfffeeaff
    2554:	6b0c      	ldr	r4, [r1, #48]	; 0x30
    2556:	0000      	movs	r0, r0
    2558:	0248      	lsls	r0, r1, #9
    255a:	0000      	movs	r0, r0
    255c:	0250      	lsls	r0, r2, #9
    255e:	0000      	movs	r0, r0
    2560:	026c      	lsls	r4, r5, #9
    2562:	0000      	movs	r0, r0
    2564:	0240      	lsls	r0, r0, #9
    2566:	0000      	movs	r0, r0
    2568:	0274      	lsls	r4, r6, #9
    256a:	0000      	movs	r0, r0
    256c:	025c      	lsls	r4, r3, #9
    256e:	0000      	movs	r0, r0
    2570:	0254      	lsls	r4, r2, #9
    2572:	0000      	movs	r0, r0
    2574:	b598      	push	{r3, r4, r7, lr}
    2576:	af00      	add	r7, sp, #0
    2578:	4b0c      	ldr	r3, [pc, #48]	; (25ac <main@@Base+0x3b0>)
    257a:	4c0d      	ldr	r4, [pc, #52]	; (25b0 <main@@Base+0x3b4>)
    257c:	447b      	add	r3, pc
    257e:	447c      	add	r4, pc
    2580:	781b      	ldrb	r3, [r3, #0]
    2582:	b993      	cbnz	r3, 25aa <main@@Base+0x3ae>
    2584:	4b0b      	ldr	r3, [pc, #44]	; (25b4 <main@@Base+0x3b8>)
    2586:	58e3      	ldr	r3, [r4, r3]
    2588:	b123      	cbz	r3, 2594 <main@@Base+0x398>
    258a:	4b0b      	ldr	r3, [pc, #44]	; (25b8 <main@@Base+0x3bc>)
    258c:	447b      	add	r3, pc
    258e:	6818      	ldr	r0, [r3, #0]
    2590:	f7ff eae8 	blx	1b64 <__cxa_finalize@plt>
    2594:	4b09      	ldr	r3, [pc, #36]	; (25bc <main@@Base+0x3c0>)
    2596:	58e3      	ldr	r3, [r4, r3]
    2598:	b11b      	cbz	r3, 25a2 <main@@Base+0x3a6>
    259a:	4809      	ldr	r0, [pc, #36]	; (25c0 <main@@Base+0x3c4>)
    259c:	4478      	add	r0, pc
    259e:	f7ff ecb8 	blx	1f10 <__deregister_frame_info@plt>
    25a2:	4b08      	ldr	r3, [pc, #32]	; (25c4 <main@@Base+0x3c8>)
    25a4:	2201      	movs	r2, #1
    25a6:	447b      	add	r3, pc
    25a8:	701a      	strb	r2, [r3, #0]
    25aa:	bd98      	pop	{r3, r4, r7, pc}
    25ac:	6d5c      	ldr	r4, [r3, #84]	; 0x54
    25ae:	0000      	movs	r0, r0
    25b0:	6a7e      	ldr	r6, [r7, #36]	; 0x24
    25b2:	0000      	movs	r0, r0
    25b4:	024c      	lsls	r4, r1, #9
    25b6:	0000      	movs	r0, r0
    25b8:	6cf0      	ldr	r0, [r6, #76]	; 0x4c
    25ba:	0000      	movs	r0, r0
    25bc:	0264      	lsls	r4, r4, #9
    25be:	0000      	movs	r0, r0
    25c0:	4c70      	ldr	r4, [pc, #448]	; (2784 <main@@Base+0x588>)
    25c2:	0000      	movs	r0, r0
    25c4:	6d32      	ldr	r2, [r6, #80]	; 0x50
    25c6:	0000      	movs	r0, r0
    25c8:	b598      	push	{r3, r4, r7, lr}
    25ca:	af00      	add	r7, sp, #0
    25cc:	4c09      	ldr	r4, [pc, #36]	; (25f4 <main@@Base+0x3f8>)
    25ce:	4b0a      	ldr	r3, [pc, #40]	; (25f8 <main@@Base+0x3fc>)
    25d0:	447c      	add	r4, pc
    25d2:	58e3      	ldr	r3, [r4, r3]
    25d4:	b12b      	cbz	r3, 25e2 <main@@Base+0x3e6>
    25d6:	4809      	ldr	r0, [pc, #36]	; (25fc <main@@Base+0x400>)
    25d8:	4909      	ldr	r1, [pc, #36]	; (2600 <main@@Base+0x404>)
    25da:	4478      	add	r0, pc
    25dc:	4479      	add	r1, pc
    25de:	f7ff ecb0 	blx	1f40 <__register_frame_info@plt>
    25e2:	4808      	ldr	r0, [pc, #32]	; (2604 <main@@Base+0x408>)
    25e4:	4478      	add	r0, pc
    25e6:	6803      	ldr	r3, [r0, #0]
    25e8:	b11b      	cbz	r3, 25f2 <main@@Base+0x3f6>
    25ea:	4b07      	ldr	r3, [pc, #28]	; (2608 <main@@Base+0x40c>)
    25ec:	58e3      	ldr	r3, [r4, r3]
    25ee:	b103      	cbz	r3, 25f2 <main@@Base+0x3f6>
    25f0:	4798      	blx	r3
    25f2:	bd98      	pop	{r3, r4, r7, pc}
    25f4:	6a2c      	ldr	r4, [r5, #32]
    25f6:	0000      	movs	r0, r0
    25f8:	0268      	lsls	r0, r5, #9
    25fa:	0000      	movs	r0, r0
    25fc:	4c32      	ldr	r4, [pc, #200]	; (26c8 <main@@Base+0x4cc>)
    25fe:	0000      	movs	r0, r0
    2600:	6d00      	ldr	r0, [r0, #80]	; 0x50
    2602:	0000      	movs	r0, r0
    2604:	6914      	ldr	r4, [r2, #16]
    2606:	0000      	movs	r0, r0
    2608:	0270      	lsls	r0, r6, #9
    260a:	0000      	movs	r0, r0
    260c:	4807      	ldr	r0, [pc, #28]	; (262c <main@@Base+0x430>)
    260e:	4908      	ldr	r1, [pc, #32]	; (2630 <main@@Base+0x434>)
    2610:	b508      	push	{r3, lr}
    2612:	4478      	add	r0, pc
    2614:	4479      	add	r1, pc
    2616:	f000 f821 	bl	265c <main@@Base+0x460>
    261a:	2800      	cmp	r0, #0
    261c:	db03      	blt.n	2626 <main@@Base+0x42a>
    261e:	bf0c      	ite	eq
    2620:	2000      	moveq	r0, #0
    2622:	2001      	movne	r0, #1
    2624:	bd08      	pop	{r3, pc}
    2626:	2000      	movs	r0, #0
    2628:	bd08      	pop	{r3, pc}
    262a:	bf00      	nop
    262c:	3026      	adds	r0, #38	; 0x26
    262e:	0000      	movs	r0, r0
    2630:	3044      	adds	r0, #68	; 0x44
    2632:	0000      	movs	r0, r0
    2634:	4807      	ldr	r0, [pc, #28]	; (2654 <main@@Base+0x458>)
    2636:	4908      	ldr	r1, [pc, #32]	; (2658 <main@@Base+0x45c>)
    2638:	b508      	push	{r3, lr}
    263a:	4478      	add	r0, pc
    263c:	4479      	add	r1, pc
    263e:	f000 f80d 	bl	265c <main@@Base+0x460>
    2642:	2800      	cmp	r0, #0
    2644:	db03      	blt.n	264e <main@@Base+0x452>
    2646:	bf0c      	ite	eq
    2648:	2000      	moveq	r0, #0
    264a:	2001      	movne	r0, #1
    264c:	bd08      	pop	{r3, pc}
    264e:	2000      	movs	r0, #0
    2650:	bd08      	pop	{r3, pc}
    2652:	bf00      	nop
    2654:	2ffe      	cmp	r7, #254	; 0xfe
    2656:	0000      	movs	r0, r0
    2658:	302d      	adds	r0, #45	; 0x2d
    265a:	0000      	movs	r0, r0
    265c:	4b4a      	ldr	r3, [pc, #296]	; (2788 <main@@Base+0x58c>)
    265e:	4a4b      	ldr	r2, [pc, #300]	; (278c <main@@Base+0x590>)
    2660:	447b      	add	r3, pc
    2662:	e92d 43f0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, lr}
    2666:	f5ad 5d9e 	sub.w	sp, sp, #5056	; 0x13c0
    266a:	589d      	ldr	r5, [r3, r2]
    266c:	b08b      	sub	sp, #44	; 0x2c
    266e:	f50d 529e 	add.w	r2, sp, #5056	; 0x13c0
    2672:	460f      	mov	r7, r1
    2674:	3224      	adds	r2, #36	; 0x24
    2676:	2100      	movs	r1, #0
    2678:	682b      	ldr	r3, [r5, #0]
    267a:	4606      	mov	r6, r0
    267c:	6013      	str	r3, [r2, #0]
    267e:	f7ff ed2c 	blx	20d8 <open@plt>
    2682:	2800      	cmp	r0, #0
    2684:	4604      	mov	r4, r0
    2686:	da0a      	bge.n	269e <main@@Base+0x4a2>
    2688:	4a41      	ldr	r2, [pc, #260]	; (2790 <main@@Base+0x594>)
    268a:	4633      	mov	r3, r6
    268c:	f242 7010 	movw	r0, #10000	; 0x2710
    2690:	2102      	movs	r1, #2
    2692:	447a      	add	r2, pc
    2694:	f04f 36ff 	mov.w	r6, #4294967295	; 0xffffffff
    2698:	f7ff eb84 	blx	1da4 <slogf@plt>
    269c:	e063      	b.n	2766 <main@@Base+0x56a>
    269e:	f50d 7879 	add.w	r8, sp, #996	; 0x3e4
    26a2:	f640 72ff 	movw	r2, #4095	; 0xfff
    26a6:	4641      	mov	r1, r8
    26a8:	f7ff ebd2 	blx	1e50 <read@plt>
    26ac:	f640 73fe 	movw	r3, #4094	; 0xffe
    26b0:	1e42      	subs	r2, r0, #1
    26b2:	429a      	cmp	r2, r3
    26b4:	d90e      	bls.n	26d4 <main@@Base+0x4d8>
    26b6:	f7ff eaac 	blx	1c10 <__get_errno_ptr@plt>
    26ba:	4a36      	ldr	r2, [pc, #216]	; (2794 <main@@Base+0x598>)
    26bc:	2102      	movs	r1, #2
    26be:	447a      	add	r2, pc
    26c0:	6803      	ldr	r3, [r0, #0]
    26c2:	f242 7010 	movw	r0, #10000	; 0x2710
    26c6:	9300      	str	r3, [sp, #0]
    26c8:	4633      	mov	r3, r6
    26ca:	f7ff eb6c 	blx	1da4 <slogf@plt>
    26ce:	f04f 36ff 	mov.w	r6, #4294967295	; 0xffffffff
    26d2:	e045      	b.n	2760 <main@@Base+0x564>
    26d4:	f04f 0900 	mov.w	r9, #0
    26d8:	4641      	mov	r1, r8
    26da:	f808 9000 	strb.w	r9, [r8, r0]
    26de:	a804      	add	r0, sp, #16
    26e0:	f7ff ec7e 	blx	1fe0 <pps_decoder_initialize@plt>
    26e4:	a804      	add	r0, sp, #16
    26e6:	4649      	mov	r1, r9
    26e8:	f7ff eb14 	blx	1d14 <pps_decoder_push@plt>
    26ec:	b150      	cbz	r0, 2704 <main@@Base+0x508>
    26ee:	4a2a      	ldr	r2, [pc, #168]	; (2798 <main@@Base+0x59c>)
    26f0:	4633      	mov	r3, r6
    26f2:	f242 7010 	movw	r0, #10000	; 0x2710
    26f6:	2102      	movs	r1, #2
    26f8:	447a      	add	r2, pc
    26fa:	f04f 36ff 	mov.w	r6, #4294967295	; 0xffffffff
    26fe:	f7ff eb52 	blx	1da4 <slogf@plt>
    2702:	e02a      	b.n	275a <main@@Base+0x55e>
    2704:	a804      	add	r0, sp, #16
    2706:	4639      	mov	r1, r7
    2708:	f7ff ebea 	blx	1ee0 <pps_decoder_type@plt>
    270c:	2801      	cmp	r0, #1
    270e:	d002      	beq.n	2716 <main@@Base+0x51a>
    2710:	2803      	cmp	r0, #3
    2712:	d11d      	bne.n	2750 <main@@Base+0x554>
    2714:	e009      	b.n	272a <main@@Base+0x52e>
    2716:	a804      	add	r0, sp, #16
    2718:	4639      	mov	r1, r7
    271a:	f10d 020f 	add.w	r2, sp, #15
    271e:	f7ff ec22 	blx	1f64 <pps_decoder_get_bool@plt>
    2722:	f89d 600f 	ldrb.w	r6, [sp, #15]
    2726:	b1a8      	cbz	r0, 2754 <main@@Base+0x558>
    2728:	e012      	b.n	2750 <main@@Base+0x554>
    272a:	a804      	add	r0, sp, #16
    272c:	4639      	mov	r1, r7
    272e:	aa02      	add	r2, sp, #8
    2730:	f7ff ecd8 	blx	20e4 <pps_decoder_get_string@plt>
    2734:	b960      	cbnz	r0, 2750 <main@@Base+0x554>
    2736:	9b02      	ldr	r3, [sp, #8]
    2738:	f993 6000 	ldrsb.w	r6, [r3]
    273c:	2e30      	cmp	r6, #48	; 0x30
    273e:	bf08      	it	eq
    2740:	4606      	moveq	r6, r0
    2742:	d007      	beq.n	2754 <main@@Base+0x558>
    2744:	2e31      	cmp	r6, #49	; 0x31
    2746:	bf14      	ite	ne
    2748:	f04f 36ff 	movne.w	r6, #4294967295	; 0xffffffff
    274c:	2601      	moveq	r6, #1
    274e:	e001      	b.n	2754 <main@@Base+0x558>
    2750:	f04f 36ff 	mov.w	r6, #4294967295	; 0xffffffff
    2754:	a804      	add	r0, sp, #16
    2756:	f7ff eca2 	blx	209c <pps_decoder_pop@plt>
    275a:	a804      	add	r0, sp, #16
    275c:	f7ff ecb6 	blx	20cc <pps_decoder_cleanup@plt>
    2760:	4620      	mov	r0, r4
    2762:	f7ff ea2c 	blx	1bbc <close@plt+0x4>
    2766:	f50d 539e 	add.w	r3, sp, #5056	; 0x13c0
    276a:	4630      	mov	r0, r6
    276c:	3324      	adds	r3, #36	; 0x24
    276e:	681a      	ldr	r2, [r3, #0]
    2770:	682b      	ldr	r3, [r5, #0]
    2772:	429a      	cmp	r2, r3
    2774:	d001      	beq.n	277a <main@@Base+0x57e>
    2776:	f7ff eaf2 	blx	1d5c <__stack_chk_fail@plt>
    277a:	f50d 7d7b 	add.w	sp, sp, #1004	; 0x3ec
    277e:	f50d 5d80 	add.w	sp, sp, #4096	; 0x1000
    2782:	e8bd 83f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, pc}
    2786:	bf00      	nop
    2788:	699c      	ldr	r4, [r3, #24]
    278a:	0000      	movs	r0, r0
    278c:	0258      	lsls	r0, r3, #9
    278e:	0000      	movs	r0, r0
    2790:	2fe8      	cmp	r7, #232	; 0xe8
    2792:	0000      	movs	r0, r0
    2794:	2fcc      	cmp	r7, #204	; 0xcc
    2796:	0000      	movs	r0, r0
    2798:	2fce      	cmp	r7, #206	; 0xce
    279a:	0000      	movs	r0, r0
    279c:	4807      	ldr	r0, [pc, #28]	; (27bc <main@@Base+0x5c0>)
    279e:	4908      	ldr	r1, [pc, #32]	; (27c0 <main@@Base+0x5c4>)
    27a0:	b508      	push	{r3, lr}
    27a2:	4478      	add	r0, pc
    27a4:	4479      	add	r1, pc
    27a6:	f7ff ff59 	bl	265c <main@@Base+0x460>
    27aa:	2800      	cmp	r0, #0
    27ac:	db03      	blt.n	27b6 <main@@Base+0x5ba>
    27ae:	bf0c      	ite	eq
    27b0:	2000      	moveq	r0, #0
    27b2:	2001      	movne	r0, #1
    27b4:	bd08      	pop	{r3, pc}
    27b6:	2000      	movs	r0, #0
    27b8:	bd08      	pop	{r3, pc}
    27ba:	bf00      	nop
    27bc:	2f57      	cmp	r7, #87	; 0x57
    27be:	0000      	movs	r0, r0
    27c0:	2f72      	cmp	r7, #114	; 0x72
    27c2:	0000      	movs	r0, r0
    27c4:	b570      	push	{r4, r5, r6, lr}
    27c6:	2500      	movs	r5, #0
    27c8:	2610      	movs	r6, #16
    27ca:	4604      	mov	r4, r0
    27cc:	2301      	movs	r3, #1
    27ce:	6045      	str	r5, [r0, #4]
    27d0:	6103      	str	r3, [r0, #16]
    27d2:	4629      	mov	r1, r5
    27d4:	f04f 33ff 	mov.w	r3, #4294967295	; 0xffffffff
    27d8:	f8c0 50f0 	str.w	r5, [r0, #240]	; 0xf0
    27dc:	f8c0 30f4 	str.w	r3, [r0, #244]	; 0xf4
    27e0:	4632      	mov	r2, r6
    27e2:	f8c0 30f8 	str.w	r3, [r0, #248]	; 0xf8
    27e6:	f8a0 511c 	strh.w	r5, [r0, #284]	; 0x11c
    27ea:	f100 00fc 	add.w	r0, r0, #252	; 0xfc
    27ee:	f7ff eaf4 	blx	1dd8 <memset@plt+0x4>
    27f2:	4629      	mov	r1, r5
    27f4:	4632      	mov	r2, r6
    27f6:	f504 7086 	add.w	r0, r4, #268	; 0x10c
    27fa:	f7ff eaee 	blx	1dd8 <memset@plt+0x4>
    27fe:	f504 708f 	add.w	r0, r4, #286	; 0x11e
    2802:	4629      	mov	r1, r5
    2804:	224f      	movs	r2, #79	; 0x4f
    2806:	f7ff eae8 	blx	1dd8 <memset@plt+0x4>
    280a:	f104 0014 	add.w	r0, r4, #20
    280e:	e8bd 4070 	ldmia.w	sp!, {r4, r5, r6, lr}
    2812:	f7ff bbdd 	b.w	1fd0 <DisposeEncryptionChallengeKeys@plt>
    2816:	b538      	push	{r3, r4, r5, lr}
    2818:	4605      	mov	r5, r0
    281a:	f7ff fef7 	bl	260c <main@@Base+0x410>
    281e:	4604      	mov	r4, r0
    2820:	b970      	cbnz	r0, 2840 <main@@Base+0x644>
    2822:	f8d5 30f0 	ldr.w	r3, [r5, #240]	; 0xf0
    2826:	b16b      	cbz	r3, 2844 <main@@Base+0x648>
    2828:	f7ff ffb8 	bl	279c <main@@Base+0x5a0>
    282c:	b960      	cbnz	r0, 2848 <main@@Base+0x64c>
    282e:	f505 7086 	add.w	r0, r5, #268	; 0x10c
    2832:	f001 fc0f 	bl	4054 <main@@Base+0x1e58>
    2836:	2800      	cmp	r0, #0
    2838:	bfb4      	ite	lt
    283a:	2013      	movlt	r0, #19
    283c:	2000      	movge	r0, #0
    283e:	bd38      	pop	{r3, r4, r5, pc}
    2840:	2000      	movs	r0, #0
    2842:	bd38      	pop	{r3, r4, r5, pc}
    2844:	2012      	movs	r0, #18
    2846:	bd38      	pop	{r3, r4, r5, pc}
    2848:	4620      	mov	r0, r4
    284a:	bd38      	pop	{r3, r4, r5, pc}
    284c:	4b3c      	ldr	r3, [pc, #240]	; (2940 <main@@Base+0x744>)
    284e:	b5f0      	push	{r4, r5, r6, r7, lr}
    2850:	4614      	mov	r4, r2
    2852:	4a3c      	ldr	r2, [pc, #240]	; (2944 <main@@Base+0x748>)
    2854:	447b      	add	r3, pc
    2856:	f5ad 7d15 	sub.w	sp, sp, #596	; 0x254
    285a:	460d      	mov	r5, r1
    285c:	4606      	mov	r6, r0
    285e:	589f      	ldr	r7, [r3, r2]
    2860:	683b      	ldr	r3, [r7, #0]
    2862:	9393      	str	r3, [sp, #588]	; 0x24c
    2864:	f7ff eb0c 	blx	1e80 <geteuid@plt>
    2868:	f7ff ec42 	blx	20f0 <getpwuid@plt>
    286c:	2800      	cmp	r0, #0
    286e:	d05a      	beq.n	2926 <main@@Base+0x72a>
    2870:	69c1      	ldr	r1, [r0, #28]
    2872:	2900      	cmp	r1, #0
    2874:	d057      	beq.n	2926 <main@@Base+0x72a>
    2876:	f991 3000 	ldrsb.w	r3, [r1]
    287a:	2b00      	cmp	r3, #0
    287c:	d053      	beq.n	2926 <main@@Base+0x72a>
    287e:	f44f 7280 	mov.w	r2, #256	; 0x100
    2882:	a813      	add	r0, sp, #76	; 0x4c
    2884:	f7ff eb38 	blx	1ef8 <strlcpy@plt>
    2888:	a913      	add	r1, sp, #76	; 0x4c
    288a:	f44f 7280 	mov.w	r2, #256	; 0x100
    288e:	a853      	add	r0, sp, #332	; 0x14c
    2890:	f7ff eb32 	blx	1ef8 <strlcpy@plt>
    2894:	492c      	ldr	r1, [pc, #176]	; (2948 <main@@Base+0x74c>)
    2896:	f44f 7280 	mov.w	r2, #256	; 0x100
    289a:	a853      	add	r0, sp, #332	; 0x14c
    289c:	4479      	add	r1, pc
    289e:	f7ff e9e4 	blx	1c68 <strlcat@plt>
    28a2:	a953      	add	r1, sp, #332	; 0x14c
    28a4:	462a      	mov	r2, r5
    28a6:	4630      	mov	r0, r6
    28a8:	f7ff eb26 	blx	1ef8 <strlcpy@plt>
    28ac:	4927      	ldr	r1, [pc, #156]	; (294c <main@@Base+0x750>)
    28ae:	4630      	mov	r0, r6
    28b0:	462a      	mov	r2, r5
    28b2:	4479      	add	r1, pc
    28b4:	f7ff e9d8 	blx	1c68 <strlcat@plt>
    28b8:	4620      	mov	r0, r4
    28ba:	2c00      	cmp	r4, #0
    28bc:	d036      	beq.n	292c <main@@Base+0x730>
    28be:	a813      	add	r0, sp, #76	; 0x4c
    28c0:	a901      	add	r1, sp, #4
    28c2:	f7ff e9a0 	blx	1c04 <stat@plt>
    28c6:	2800      	cmp	r0, #0
    28c8:	d12d      	bne.n	2926 <main@@Base+0x72a>
    28ca:	990c      	ldr	r1, [sp, #48]	; 0x30
    28cc:	f011 0f12 	tst.w	r1, #18
    28d0:	d00e      	beq.n	28f0 <main@@Base+0x6f4>
    28d2:	f021 0112 	bic.w	r1, r1, #18
    28d6:	a813      	add	r0, sp, #76	; 0x4c
    28d8:	f7ff ec8a 	blx	21f0 <chmod@plt>
    28dc:	a813      	add	r0, sp, #76	; 0x4c
    28de:	a901      	add	r1, sp, #4
    28e0:	f7ff e990 	blx	1c04 <stat@plt>
    28e4:	b9f8      	cbnz	r0, 2926 <main@@Base+0x72a>
    28e6:	9b0c      	ldr	r3, [sp, #48]	; 0x30
    28e8:	2006      	movs	r0, #6
    28ea:	f013 0f12 	tst.w	r3, #18
    28ee:	d11d      	bne.n	292c <main@@Base+0x730>
    28f0:	a853      	add	r0, sp, #332	; 0x14c
    28f2:	a901      	add	r1, sp, #4
    28f4:	f7ff e986 	blx	1c04 <stat@plt>
    28f8:	3001      	adds	r0, #1
    28fa:	d116      	bne.n	292a <main@@Base+0x72e>
    28fc:	f7ff e988 	blx	1c10 <__get_errno_ptr@plt>
    2900:	6803      	ldr	r3, [r0, #0]
    2902:	2008      	movs	r0, #8
    2904:	2b02      	cmp	r3, #2
    2906:	d111      	bne.n	292c <main@@Base+0x730>
    2908:	f44f 71e0 	mov.w	r1, #448	; 0x1c0
    290c:	a853      	add	r0, sp, #332	; 0x14c
    290e:	f7ff eb06 	blx	1f1c <mkdir@plt>
    2912:	a853      	add	r0, sp, #332	; 0x14c
    2914:	a901      	add	r1, sp, #4
    2916:	f7ff e976 	blx	1c04 <stat@plt>
    291a:	f1b0 3fff 	cmp.w	r0, #4294967295	; 0xffffffff
    291e:	bf0c      	ite	eq
    2920:	2007      	moveq	r0, #7
    2922:	2000      	movne	r0, #0
    2924:	e002      	b.n	292c <main@@Base+0x730>
    2926:	2005      	movs	r0, #5
    2928:	e000      	b.n	292c <main@@Base+0x730>
    292a:	2000      	movs	r0, #0
    292c:	9a93      	ldr	r2, [sp, #588]	; 0x24c
    292e:	683b      	ldr	r3, [r7, #0]
    2930:	429a      	cmp	r2, r3
    2932:	d001      	beq.n	2938 <main@@Base+0x73c>
    2934:	f7ff ea12 	blx	1d5c <__stack_chk_fail@plt>
    2938:	f50d 7d15 	add.w	sp, sp, #596	; 0x254
    293c:	bdf0      	pop	{r4, r5, r6, r7, pc}
    293e:	bf00      	nop
    2940:	67a8      	str	r0, [r5, #120]	; 0x78
    2942:	0000      	movs	r0, r0
    2944:	0258      	lsls	r0, r3, #9
    2946:	0000      	movs	r0, r0
    2948:	3107      	adds	r1, #7
    294a:	0000      	movs	r0, r0
    294c:	32b1      	adds	r2, #177	; 0xb1
    294e:	0000      	movs	r0, r0
    2950:	e92d 41ff 	stmdb	sp!, {r0, r1, r2, r3, r4, r5, r6, r7, r8, lr}
    2954:	4606      	mov	r6, r0
    2956:	4b37      	ldr	r3, [pc, #220]	; (2a34 <main@@Base+0x838>)
    2958:	4a37      	ldr	r2, [pc, #220]	; (2a38 <main@@Base+0x83c>)
    295a:	447b      	add	r3, pc
    295c:	589c      	ldr	r4, [r3, r2]
    295e:	6822      	ldr	r2, [r4, #0]
    2960:	9203      	str	r2, [sp, #12]
    2962:	4a36      	ldr	r2, [pc, #216]	; (2a3c <main@@Base+0x840>)
    2964:	589d      	ldr	r5, [r3, r2]
    2966:	4603      	mov	r3, r0
    2968:	1840      	adds	r0, r0, r1
    296a:	682f      	ldr	r7, [r5, #0]
    296c:	e00a      	b.n	2984 <main@@Base+0x788>
    296e:	f992 2000 	ldrsb.w	r2, [r2]
    2972:	3301      	adds	r3, #1
    2974:	f837 c012 	ldrh.w	ip, [r7, r2, lsl #1]
    2978:	f240 223e 	movw	r2, #574	; 0x23e
    297c:	ea0c 0202 	and.w	r2, ip, r2
    2980:	2a00      	cmp	r2, #0
    2982:	d04c      	beq.n	2a1e <main@@Base+0x822>
    2984:	4283      	cmp	r3, r0
    2986:	461a      	mov	r2, r3
    2988:	d3f1      	bcc.n	296e <main@@Base+0x772>
    298a:	1c4f      	adds	r7, r1, #1
    298c:	4638      	mov	r0, r7
    298e:	f7ff ec24 	blx	21d8 <malloc@plt>
    2992:	4631      	mov	r1, r6
    2994:	463a      	mov	r2, r7
    2996:	2600      	movs	r6, #0
    2998:	9002      	str	r0, [sp, #8]
    299a:	f7ff eaae 	blx	1ef8 <strlcpy@plt>
    299e:	4668      	mov	r0, sp
    29a0:	a902      	add	r1, sp, #8
    29a2:	9f02      	ldr	r7, [sp, #8]
    29a4:	9600      	str	r6, [sp, #0]
    29a6:	9601      	str	r6, [sp, #4]
    29a8:	f001 fd72 	bl	4490 <main@@Base+0x2294>
    29ac:	2801      	cmp	r0, #1
    29ae:	d12b      	bne.n	2a08 <main@@Base+0x80c>
    29b0:	9801      	ldr	r0, [sp, #4]
    29b2:	f7ff e948 	blx	1c44 <RSA_size@plt>
    29b6:	f5b0 7f00 	cmp.w	r0, #512	; 0x200
    29ba:	db27      	blt.n	2a0c <main@@Base+0x810>
    29bc:	f8dd 8008 	ldr.w	r8, [sp, #8]
    29c0:	4640      	mov	r0, r8
    29c2:	f7ff ebc2 	blx	2148 <strlen@plt>
    29c6:	b318      	cbz	r0, 2a10 <main@@Base+0x814>
    29c8:	f998 3000 	ldrsb.w	r3, [r8]
    29cc:	4440      	add	r0, r8
    29ce:	2b20      	cmp	r3, #32
    29d0:	bf08      	it	eq
    29d2:	682d      	ldreq	r5, [r5, #0]
    29d4:	d11e      	bne.n	2a14 <main@@Base+0x818>
    29d6:	e00e      	b.n	29f6 <main@@Base+0x7fa>
    29d8:	f998 3001 	ldrsb.w	r3, [r8, #1]
    29dc:	f240 223e 	movw	r2, #574	; 0x23e
    29e0:	f835 e013 	ldrh.w	lr, [r5, r3, lsl #1]
    29e4:	ea0e 0202 	and.w	r2, lr, r2
    29e8:	b1a2      	cbz	r2, 2a14 <main@@Base+0x818>
    29ea:	2b20      	cmp	r3, #32
    29ec:	d012      	beq.n	2a14 <main@@Base+0x818>
    29ee:	2b40      	cmp	r3, #64	; 0x40
    29f0:	bf08      	it	eq
    29f2:	2601      	moveq	r6, #1
    29f4:	4688      	mov	r8, r1
    29f6:	f108 0101 	add.w	r1, r8, #1
    29fa:	4288      	cmp	r0, r1
    29fc:	d8ec      	bhi.n	29d8 <main@@Base+0x7dc>
    29fe:	2e00      	cmp	r6, #0
    2a00:	bf0c      	ite	eq
    2a02:	2610      	moveq	r6, #16
    2a04:	2600      	movne	r6, #0
    2a06:	e006      	b.n	2a16 <main@@Base+0x81a>
    2a08:	260e      	movs	r6, #14
    2a0a:	e004      	b.n	2a16 <main@@Base+0x81a>
    2a0c:	260f      	movs	r6, #15
    2a0e:	e002      	b.n	2a16 <main@@Base+0x81a>
    2a10:	4606      	mov	r6, r0
    2a12:	e000      	b.n	2a16 <main@@Base+0x81a>
    2a14:	2610      	movs	r6, #16
    2a16:	4638      	mov	r0, r7
    2a18:	f7ff e908 	blx	1c2c <free@plt+0x4>
    2a1c:	e000      	b.n	2a20 <main@@Base+0x824>
    2a1e:	260e      	movs	r6, #14
    2a20:	9a03      	ldr	r2, [sp, #12]
    2a22:	4630      	mov	r0, r6
    2a24:	6823      	ldr	r3, [r4, #0]
    2a26:	429a      	cmp	r2, r3
    2a28:	d001      	beq.n	2a2e <main@@Base+0x832>
    2a2a:	f7ff e998 	blx	1d5c <__stack_chk_fail@plt>
    2a2e:	b004      	add	sp, #16
    2a30:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
    2a34:	66a2      	str	r2, [r4, #104]	; 0x68
    2a36:	0000      	movs	r0, r0
    2a38:	0258      	lsls	r0, r3, #9
    2a3a:	0000      	movs	r0, r0
    2a3c:	0278      	lsls	r0, r7, #9
    2a3e:	0000      	movs	r0, r0
    2a40:	b538      	push	{r3, r4, r5, lr}
    2a42:	4605      	mov	r5, r0
    2a44:	f7ff eb24 	blx	2090 <getpwnam@plt>
    2a48:	4604      	mov	r4, r0
    2a4a:	b1a8      	cbz	r0, 2a78 <main@@Base+0x87c>
    2a4c:	490d      	ldr	r1, [pc, #52]	; (2a84 <main@@Base+0x888>)
    2a4e:	4628      	mov	r0, r5
    2a50:	4479      	add	r1, pc
    2a52:	f7ff ebc8 	blx	21e4 <strcmp@plt>
    2a56:	b908      	cbnz	r0, 2a5c <main@@Base+0x860>
    2a58:	68a3      	ldr	r3, [r4, #8]
    2a5a:	b17b      	cbz	r3, 2a7c <main@@Base+0x880>
    2a5c:	68e0      	ldr	r0, [r4, #12]
    2a5e:	f7ff e8f8 	blx	1c50 <setegid@plt>
    2a62:	3001      	adds	r0, #1
    2a64:	d00c      	beq.n	2a80 <main@@Base+0x884>
    2a66:	68a0      	ldr	r0, [r4, #8]
    2a68:	f7ff e92e 	blx	1cc8 <seteuid@plt>
    2a6c:	f1b0 3fff 	cmp.w	r0, #4294967295	; 0xffffffff
    2a70:	bf0c      	ite	eq
    2a72:	200d      	moveq	r0, #13
    2a74:	2000      	movne	r0, #0
    2a76:	bd38      	pop	{r3, r4, r5, pc}
    2a78:	2005      	movs	r0, #5
    2a7a:	bd38      	pop	{r3, r4, r5, pc}
    2a7c:	200d      	movs	r0, #13
    2a7e:	bd38      	pop	{r3, r4, r5, pc}
    2a80:	200d      	movs	r0, #13
    2a82:	bd38      	pop	{r3, r4, r5, pc}
    2a84:	3140      	adds	r1, #64	; 0x40
    2a86:	0000      	movs	r0, r0
    2a88:	4b1e      	ldr	r3, [pc, #120]	; (2b04 <main@@Base+0x908>)
    2a8a:	4a1f      	ldr	r2, [pc, #124]	; (2b08 <main@@Base+0x90c>)
    2a8c:	447b      	add	r3, pc
    2a8e:	b530      	push	{r4, r5, lr}
    2a90:	b095      	sub	sp, #84	; 0x54
    2a92:	589c      	ldr	r4, [r3, r2]
    2a94:	2500      	movs	r5, #0
    2a96:	9011      	str	r0, [sp, #68]	; 0x44
    2a98:	a802      	add	r0, sp, #8
    2a9a:	9110      	str	r1, [sp, #64]	; 0x40
    2a9c:	6823      	ldr	r3, [r4, #0]
    2a9e:	9512      	str	r5, [sp, #72]	; 0x48
    2aa0:	9313      	str	r3, [sp, #76]	; 0x4c
    2aa2:	4b1a      	ldr	r3, [pc, #104]	; (2b0c <main@@Base+0x910>)
    2aa4:	447b      	add	r3, pc
    2aa6:	930e      	str	r3, [sp, #56]	; 0x38
    2aa8:	4b19      	ldr	r3, [pc, #100]	; (2b10 <main@@Base+0x914>)
    2aaa:	447b      	add	r3, pc
    2aac:	930f      	str	r3, [sp, #60]	; 0x3c
    2aae:	f7ff e860 	blx	1b70 <posix_spawnattr_init@plt>
    2ab2:	a914      	add	r1, sp, #80	; 0x50
    2ab4:	230b      	movs	r3, #11
    2ab6:	a802      	add	r0, sp, #8
    2ab8:	f841 3d40 	str.w	r3, [r1, #-64]!
    2abc:	f7ff e9f2 	blx	1ea4 <posix_spawnattr_setschedparam@plt>
    2ac0:	490f      	ldr	r1, [pc, #60]	; (2b00 <main@@Base+0x904>)
    2ac2:	a802      	add	r0, sp, #8
    2ac4:	f7ff e8ee 	blx	1ca4 <posix_spawnattr_setxflags@plt>
    2ac8:	4629      	mov	r1, r5
    2aca:	462a      	mov	r2, r5
    2acc:	a802      	add	r0, sp, #8
    2ace:	f7ff e928 	blx	1d20 <posix_spawnattr_setcred@plt>
    2ad2:	462a      	mov	r2, r5
    2ad4:	ab0e      	add	r3, sp, #56	; 0x38
    2ad6:	990e      	ldr	r1, [sp, #56]	; 0x38
    2ad8:	e88d 0028 	stmia.w	sp, {r3, r5}
    2adc:	a803      	add	r0, sp, #12
    2ade:	ab02      	add	r3, sp, #8
    2ae0:	f7ff e95a 	blx	1d98 <posix_spawn@plt>
    2ae4:	4605      	mov	r5, r0
    2ae6:	a802      	add	r0, sp, #8
    2ae8:	f7ff ea48 	blx	1f7c <posix_spawnattr_destroy@plt>
    2aec:	9a13      	ldr	r2, [sp, #76]	; 0x4c
    2aee:	6823      	ldr	r3, [r4, #0]
    2af0:	4628      	mov	r0, r5
    2af2:	429a      	cmp	r2, r3
    2af4:	d001      	beq.n	2afa <main@@Base+0x8fe>
    2af6:	f7ff e932 	blx	1d5c <__stack_chk_fail@plt>
    2afa:	b015      	add	sp, #84	; 0x54
    2afc:	bd30      	pop	{r4, r5, pc}
    2afe:	bf00      	nop
    2b00:	0400      	lsls	r0, r0, #16
    2b02:	0008      	movs	r0, r1
    2b04:	6570      	str	r0, [r6, #84]	; 0x54
    2b06:	0000      	movs	r0, r0
    2b08:	0258      	lsls	r0, r3, #9
    2b0a:	0000      	movs	r0, r0
    2b0c:	2f05      	cmp	r7, #5
    2b0e:	0000      	movs	r0, r0
    2b10:	2f0a      	cmp	r7, #10
    2b12:	0000      	movs	r0, r0
    2b14:	4b15      	ldr	r3, [pc, #84]	; (2b6c <main@@Base+0x970>)
    2b16:	4a16      	ldr	r2, [pc, #88]	; (2b70 <main@@Base+0x974>)
    2b18:	447b      	add	r3, pc
    2b1a:	b530      	push	{r4, r5, lr}
    2b1c:	b0c3      	sub	sp, #268	; 0x10c
    2b1e:	589c      	ldr	r4, [r3, r2]
    2b20:	6823      	ldr	r3, [r4, #0]
    2b22:	9341      	str	r3, [sp, #260]	; 0x104
    2b24:	f8d0 30f0 	ldr.w	r3, [r0, #240]	; 0xf0
    2b28:	b933      	cbnz	r3, 2b38 <main@@Base+0x93c>
    2b2a:	4812      	ldr	r0, [pc, #72]	; (2b74 <main@@Base+0x978>)
    2b2c:	4478      	add	r0, pc
    2b2e:	f7ff ff87 	bl	2a40 <main@@Base+0x844>
    2b32:	4605      	mov	r5, r0
    2b34:	b130      	cbz	r0, 2b44 <main@@Base+0x948>
    2b36:	e010      	b.n	2b5a <main@@Base+0x95e>
    2b38:	480f      	ldr	r0, [pc, #60]	; (2b78 <main@@Base+0x97c>)
    2b3a:	4910      	ldr	r1, [pc, #64]	; (2b7c <main@@Base+0x980>)
    2b3c:	4478      	add	r0, pc
    2b3e:	4479      	add	r1, pc
    2b40:	f7ff ffa2 	bl	2a88 <main@@Base+0x88c>
    2b44:	a801      	add	r0, sp, #4
    2b46:	f44f 7180 	mov.w	r1, #256	; 0x100
    2b4a:	2200      	movs	r2, #0
    2b4c:	f7ff fe7e 	bl	284c <main@@Base+0x650>
    2b50:	4605      	mov	r5, r0
    2b52:	b910      	cbnz	r0, 2b5a <main@@Base+0x95e>
    2b54:	a801      	add	r0, sp, #4
    2b56:	f7ff e8ac 	blx	1cb0 <unlink@plt>
    2b5a:	9a41      	ldr	r2, [sp, #260]	; 0x104
    2b5c:	4628      	mov	r0, r5
    2b5e:	6823      	ldr	r3, [r4, #0]
    2b60:	429a      	cmp	r2, r3
    2b62:	d001      	beq.n	2b68 <main@@Base+0x96c>
    2b64:	f7ff e8fa 	blx	1d5c <__stack_chk_fail@plt>
    2b68:	b043      	add	sp, #268	; 0x10c
    2b6a:	bd30      	pop	{r4, r5, pc}
    2b6c:	64e4      	str	r4, [r4, #76]	; 0x4c
    2b6e:	0000      	movs	r0, r0
    2b70:	0258      	lsls	r0, r3, #9
    2b72:	0000      	movs	r0, r0
    2b74:	3064      	adds	r0, #100	; 0x64
    2b76:	0000      	movs	r0, r0
    2b78:	2e7c      	cmp	r6, #124	; 0x7c
    2b7a:	0000      	movs	r0, r0
    2b7c:	2e89      	cmp	r6, #137	; 0x89
    2b7e:	0000      	movs	r0, r0
    2b80:	4b52      	ldr	r3, [pc, #328]	; (2ccc <main@@Base+0xad0>)
    2b82:	e92d 47f0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, lr}
    2b86:	4616      	mov	r6, r2
    2b88:	4a51      	ldr	r2, [pc, #324]	; (2cd0 <main@@Base+0xad4>)
    2b8a:	447b      	add	r3, pc
    2b8c:	460f      	mov	r7, r1
    2b8e:	4951      	ldr	r1, [pc, #324]	; (2cd4 <main@@Base+0xad8>)
    2b90:	f5ad 7d2a 	sub.w	sp, sp, #680	; 0x2a8
    2b94:	4681      	mov	r9, r0
    2b96:	589d      	ldr	r5, [r3, r2]
    2b98:	4479      	add	r1, pc
    2b9a:	2202      	movs	r2, #2
    2b9c:	a865      	add	r0, sp, #404	; 0x194
    2b9e:	682b      	ldr	r3, [r5, #0]
    2ba0:	46a8      	mov	r8, r5
    2ba2:	93a9      	str	r3, [sp, #676]	; 0x2a4
    2ba4:	f7ff e8b0 	blx	1d08 <memcpy@plt+0x4>
    2ba8:	2100      	movs	r1, #0
    2baa:	22fe      	movs	r2, #254	; 0xfe
    2bac:	f50d 70cb 	add.w	r0, sp, #406	; 0x196
    2bb0:	f7ff e912 	blx	1dd8 <memset@plt+0x4>
    2bb4:	4648      	mov	r0, r9
    2bb6:	f7ff ffad 	bl	2b14 <main@@Base+0x918>
    2bba:	4638      	mov	r0, r7
    2bbc:	4631      	mov	r1, r6
    2bbe:	f7ff fec7 	bl	2950 <main@@Base+0x754>
    2bc2:	4604      	mov	r4, r0
    2bc4:	2800      	cmp	r0, #0
    2bc6:	d175      	bne.n	2cb4 <main@@Base+0xab8>
    2bc8:	a825      	add	r0, sp, #148	; 0x94
    2bca:	f44f 7180 	mov.w	r1, #256	; 0x100
    2bce:	2201      	movs	r2, #1
    2bd0:	f7ff fe3c 	bl	284c <main@@Base+0x650>
    2bd4:	4604      	mov	r4, r0
    2bd6:	2800      	cmp	r0, #0
    2bd8:	d16c      	bne.n	2cb4 <main@@Base+0xab8>
    2bda:	a825      	add	r0, sp, #148	; 0x94
    2bdc:	a901      	add	r1, sp, #4
    2bde:	f7ff e8ca 	blx	1d74 <lstat@plt>
    2be2:	3001      	adds	r0, #1
    2be4:	bf18      	it	ne
    2be6:	f04f 0a01 	movne.w	sl, #1
    2bea:	d106      	bne.n	2bfa <main@@Base+0x9fe>
    2bec:	f7ff e810 	blx	1c10 <__get_errno_ptr@plt>
    2bf0:	6803      	ldr	r3, [r0, #0]
    2bf2:	2b02      	cmp	r3, #2
    2bf4:	bf08      	it	eq
    2bf6:	46a2      	moveq	sl, r4
    2bf8:	d15b      	bne.n	2cb2 <main@@Base+0xab6>
    2bfa:	4937      	ldr	r1, [pc, #220]	; (2cd8 <main@@Base+0xadc>)
    2bfc:	a825      	add	r0, sp, #148	; 0x94
    2bfe:	4479      	add	r1, pc
    2c00:	f7ff e980 	blx	1f04 <fopen@plt>
    2c04:	4605      	mov	r5, r0
    2c06:	2800      	cmp	r0, #0
    2c08:	d053      	beq.n	2cb2 <main@@Base+0xab6>
    2c0a:	f7ff e8c0 	blx	1d8c <fileno@plt>
    2c0e:	a913      	add	r1, sp, #76	; 0x4c
    2c10:	f7ff e8b6 	blx	1d80 <fstat@plt>
    2c14:	3001      	adds	r0, #1
    2c16:	d014      	beq.n	2c42 <main@@Base+0xa46>
    2c18:	9b1e      	ldr	r3, [sp, #120]	; 0x78
    2c1a:	f1ba 0f00 	cmp.w	sl, #0
    2c1e:	d105      	bne.n	2c2c <main@@Base+0xa30>
    2c20:	f403 4370 	and.w	r3, r3, #61440	; 0xf000
    2c24:	f5b3 4f20 	cmp.w	r3, #40960	; 0xa000
    2c28:	d10f      	bne.n	2c4a <main@@Base+0xa4e>
    2c2a:	e00a      	b.n	2c42 <main@@Base+0xa46>
    2c2c:	9a0c      	ldr	r2, [sp, #48]	; 0x30
    2c2e:	429a      	cmp	r2, r3
    2c30:	d107      	bne.n	2c42 <main@@Base+0xa46>
    2c32:	9a01      	ldr	r2, [sp, #4]
    2c34:	9b13      	ldr	r3, [sp, #76]	; 0x4c
    2c36:	429a      	cmp	r2, r3
    2c38:	d103      	bne.n	2c42 <main@@Base+0xa46>
    2c3a:	9a05      	ldr	r2, [sp, #20]
    2c3c:	9b17      	ldr	r3, [sp, #92]	; 0x5c
    2c3e:	429a      	cmp	r2, r3
    2c40:	d003      	beq.n	2c4a <main@@Base+0xa4e>
    2c42:	4628      	mov	r0, r5
    2c44:	f7ff e9e8 	blx	2018 <fclose@plt>
    2c48:	e033      	b.n	2cb2 <main@@Base+0xab6>
    2c4a:	2310      	movs	r3, #16
    2c4c:	f509 7180 	add.w	r1, r9, #256	; 0x100
    2c50:	aaa5      	add	r2, sp, #660	; 0x294
    2c52:	2002      	movs	r0, #2
    2c54:	f7ff e9f2 	blx	203c <inet_ntop@plt>
    2c58:	4920      	ldr	r1, [pc, #128]	; (2cdc <main@@Base+0xae0>)
    2c5a:	f44f 7280 	mov.w	r2, #256	; 0x100
    2c5e:	4479      	add	r1, pc
    2c60:	4681      	mov	r9, r0
    2c62:	a865      	add	r0, sp, #404	; 0x194
    2c64:	f7ff e800 	blx	1c68 <strlcat@plt>
    2c68:	4649      	mov	r1, r9
    2c6a:	a865      	add	r0, sp, #404	; 0x194
    2c6c:	f44f 7280 	mov.w	r2, #256	; 0x100
    2c70:	f7fe effa 	blx	1c68 <strlcat@plt>
    2c74:	491a      	ldr	r1, [pc, #104]	; (2ce0 <main@@Base+0xae4>)
    2c76:	f44f 7280 	mov.w	r2, #256	; 0x100
    2c7a:	a865      	add	r0, sp, #404	; 0x194
    2c7c:	4479      	add	r1, pc
    2c7e:	f7fe eff4 	blx	1c68 <strlcat@plt>
    2c82:	a865      	add	r0, sp, #404	; 0x194
    2c84:	f7ff ea60 	blx	2148 <strlen@plt>
    2c88:	2101      	movs	r1, #1
    2c8a:	462b      	mov	r3, r5
    2c8c:	4602      	mov	r2, r0
    2c8e:	a865      	add	r0, sp, #404	; 0x194
    2c90:	f7ff e920 	blx	1ed4 <fwrite@plt>
    2c94:	2101      	movs	r1, #1
    2c96:	4632      	mov	r2, r6
    2c98:	462b      	mov	r3, r5
    2c9a:	4638      	mov	r0, r7
    2c9c:	f7ff e91a 	blx	1ed4 <fwrite@plt>
    2ca0:	4628      	mov	r0, r5
    2ca2:	f7ff e9ba 	blx	2018 <fclose@plt>
    2ca6:	a825      	add	r0, sp, #148	; 0x94
    2ca8:	f44f 71c0 	mov.w	r1, #384	; 0x180
    2cac:	f7ff eaa0 	blx	21f0 <chmod@plt>
    2cb0:	e000      	b.n	2cb4 <main@@Base+0xab8>
    2cb2:	2409      	movs	r4, #9
    2cb4:	9aa9      	ldr	r2, [sp, #676]	; 0x2a4
    2cb6:	4620      	mov	r0, r4
    2cb8:	f8d8 3000 	ldr.w	r3, [r8]
    2cbc:	429a      	cmp	r2, r3
    2cbe:	d001      	beq.n	2cc4 <main@@Base+0xac8>
    2cc0:	f7ff e84c 	blx	1d5c <__stack_chk_fail@plt>
    2cc4:	f50d 7d2a 	add.w	sp, sp, #680	; 0x2a8
    2cc8:	e8bd 87f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, pc}
    2ccc:	6472      	str	r2, [r6, #68]	; 0x44
    2cce:	0000      	movs	r0, r0
    2cd0:	0258      	lsls	r0, r3, #9
    2cd2:	0000      	movs	r0, r0
    2cd4:	2b8b      	cmp	r3, #139	; 0x8b
    2cd6:	0000      	movs	r0, r0
    2cd8:	2ddd      	cmp	r5, #221	; 0xdd
    2cda:	0000      	movs	r0, r0
    2cdc:	2d7f      	cmp	r5, #127	; 0x7f
    2cde:	0000      	movs	r0, r0
    2ce0:	2d68      	cmp	r5, #104	; 0x68
    2ce2:	0000      	movs	r0, r0
    2ce4:	4b23      	ldr	r3, [pc, #140]	; (2d74 <main@@Base+0xb78>)
    2ce6:	4a24      	ldr	r2, [pc, #144]	; (2d78 <main@@Base+0xb7c>)
    2ce8:	447b      	add	r3, pc
    2cea:	b570      	push	{r4, r5, r6, lr}
    2cec:	b094      	sub	sp, #80	; 0x50
    2cee:	589c      	ldr	r4, [r3, r2]
    2cf0:	2500      	movs	r5, #0
    2cf2:	900f      	str	r0, [sp, #60]	; 0x3c
    2cf4:	a803      	add	r0, sp, #12
    2cf6:	460e      	mov	r6, r1
    2cf8:	9510      	str	r5, [sp, #64]	; 0x40
    2cfa:	6823      	ldr	r3, [r4, #0]
    2cfc:	9313      	str	r3, [sp, #76]	; 0x4c
    2cfe:	4b1f      	ldr	r3, [pc, #124]	; (2d7c <main@@Base+0xb80>)
    2d00:	447b      	add	r3, pc
    2d02:	930e      	str	r3, [sp, #56]	; 0x38
    2d04:	f7fe ef34 	blx	1b70 <posix_spawnattr_init@plt>
    2d08:	a914      	add	r1, sp, #80	; 0x50
    2d0a:	230b      	movs	r3, #11
    2d0c:	a803      	add	r0, sp, #12
    2d0e:	f841 3d40 	str.w	r3, [r1, #-64]!
    2d12:	f7ff e8c8 	blx	1ea4 <posix_spawnattr_setschedparam@plt>
    2d16:	4916      	ldr	r1, [pc, #88]	; (2d70 <main@@Base+0xb74>)
    2d18:	a803      	add	r0, sp, #12
    2d1a:	f7fe efc4 	blx	1ca4 <posix_spawnattr_setxflags@plt>
    2d1e:	4629      	mov	r1, r5
    2d20:	a803      	add	r0, sp, #12
    2d22:	f7ff ea2a 	blx	2178 <posix_spawnattr_setpgroup@plt>
    2d26:	4629      	mov	r1, r5
    2d28:	462a      	mov	r2, r5
    2d2a:	a803      	add	r0, sp, #12
    2d2c:	f7fe eff8 	blx	1d20 <posix_spawnattr_setcred@plt>
    2d30:	4629      	mov	r1, r5
    2d32:	aa11      	add	r2, sp, #68	; 0x44
    2d34:	4628      	mov	r0, r5
    2d36:	f7fe ef34 	blx	1ba0 <pthread_sigmask@plt>
    2d3a:	a911      	add	r1, sp, #68	; 0x44
    2d3c:	a803      	add	r0, sp, #12
    2d3e:	f7fe ef8e 	blx	1c5c <posix_spawnattr_setsigmask@plt>
    2d42:	462a      	mov	r2, r5
    2d44:	ab0e      	add	r3, sp, #56	; 0x38
    2d46:	990e      	ldr	r1, [sp, #56]	; 0x38
    2d48:	e88d 0028 	stmia.w	sp, {r3, r5}
    2d4c:	4630      	mov	r0, r6
    2d4e:	ab03      	add	r3, sp, #12
    2d50:	f7ff e822 	blx	1d98 <posix_spawn@plt>
    2d54:	4605      	mov	r5, r0
    2d56:	a803      	add	r0, sp, #12
    2d58:	f7ff e910 	blx	1f7c <posix_spawnattr_destroy@plt>
    2d5c:	9a13      	ldr	r2, [sp, #76]	; 0x4c
    2d5e:	6823      	ldr	r3, [r4, #0]
    2d60:	4628      	mov	r0, r5
    2d62:	429a      	cmp	r2, r3
    2d64:	d001      	beq.n	2d6a <main@@Base+0xb6e>
    2d66:	f7fe effa 	blx	1d5c <__stack_chk_fail@plt>
    2d6a:	b014      	add	sp, #80	; 0x50
    2d6c:	bd70      	pop	{r4, r5, r6, pc}
    2d6e:	bf00      	nop
    2d70:	0403      	lsls	r3, r0, #16
    2d72:	0008      	movs	r0, r1
    2d74:	6314      	str	r4, [r2, #48]	; 0x30
    2d76:	0000      	movs	r0, r0
    2d78:	0258      	lsls	r0, r3, #9
    2d7a:	0000      	movs	r0, r0
    2d7c:	2cf2      	cmp	r4, #242	; 0xf2
    2d7e:	0000      	movs	r0, r0
    2d80:	b537      	push	{r0, r1, r2, r4, r5, lr}
    2d82:	4605      	mov	r5, r0
    2d84:	f8d0 10f4 	ldr.w	r1, [r0, #244]	; 0xf4
    2d88:	2900      	cmp	r1, #0
    2d8a:	dd11      	ble.n	2db0 <main@@Base+0xbb4>
    2d8c:	2400      	movs	r4, #0
    2d8e:	230f      	movs	r3, #15
    2d90:	9400      	str	r4, [sp, #0]
    2d92:	4620      	mov	r0, r4
    2d94:	4622      	mov	r2, r4
    2d96:	9401      	str	r4, [sp, #4]
    2d98:	f7ff e854 	blx	1e44 <SignalKill_r@plt>
    2d9c:	b140      	cbz	r0, 2db0 <main@@Base+0xbb4>
    2d9e:	4620      	mov	r0, r4
    2da0:	f8d5 10f4 	ldr.w	r1, [r5, #244]	; 0xf4
    2da4:	4622      	mov	r2, r4
    2da6:	2309      	movs	r3, #9
    2da8:	9400      	str	r4, [sp, #0]
    2daa:	9401      	str	r4, [sp, #4]
    2dac:	f7ff e84a 	blx	1e44 <SignalKill_r@plt>
    2db0:	480a      	ldr	r0, [pc, #40]	; (2ddc <main@@Base+0xbe0>)
    2db2:	f04f 34ff 	mov.w	r4, #4294967295	; 0xffffffff
    2db6:	f8c5 40f4 	str.w	r4, [r5, #244]	; 0xf4
    2dba:	4478      	add	r0, pc
    2dbc:	f001 fa28 	bl	4210 <main@@Base+0x2014>
    2dc0:	f8c5 40f8 	str.w	r4, [r5, #248]	; 0xf8
    2dc4:	4628      	mov	r0, r5
    2dc6:	f7ff fea5 	bl	2b14 <main@@Base+0x918>
    2dca:	f8d5 30f0 	ldr.w	r3, [r5, #240]	; 0xf0
    2dce:	b91b      	cbnz	r3, 2dd8 <main@@Base+0xbdc>
    2dd0:	4803      	ldr	r0, [pc, #12]	; (2de0 <main@@Base+0xbe4>)
    2dd2:	4478      	add	r0, pc
    2dd4:	f7ff fe34 	bl	2a40 <main@@Base+0x844>
    2dd8:	2000      	movs	r0, #0
    2dda:	bd3e      	pop	{r1, r2, r3, r4, r5, pc}
    2ddc:	2e0b      	cmp	r6, #11
    2dde:	0000      	movs	r0, r0
    2de0:	2beb      	cmp	r3, #235	; 0xeb
    2de2:	0000      	movs	r0, r0
    2de4:	4b4a      	ldr	r3, [pc, #296]	; (2f10 <main@@Base+0xd14>)
    2de6:	4a4b      	ldr	r2, [pc, #300]	; (2f14 <main@@Base+0xd18>)
    2de8:	e92d 43f0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, lr}
    2dec:	447b      	add	r3, pc
    2dee:	f8df 9128 	ldr.w	r9, [pc, #296]	; 2f18 <main@@Base+0xd1c>
    2df2:	b08d      	sub	sp, #52	; 0x34
    2df4:	589d      	ldr	r5, [r3, r2]
    2df6:	4604      	mov	r4, r0
    2df8:	44f9      	add	r9, pc
    2dfa:	460f      	mov	r7, r1
    2dfc:	f8d9 8000 	ldr.w	r8, [r9]
    2e00:	682b      	ldr	r3, [r5, #0]
    2e02:	f1b8 3fff 	cmp.w	r8, #4294967295	; 0xffffffff
    2e06:	930b      	str	r3, [sp, #44]	; 0x2c
    2e08:	d11f      	bne.n	2e4a <main@@Base+0xc4e>
    2e0a:	4e44      	ldr	r6, [pc, #272]	; (2f1c <main@@Base+0xd20>)
    2e0c:	f240 3101 	movw	r1, #769	; 0x301
    2e10:	f44f 72d2 	mov.w	r2, #420	; 0x1a4
    2e14:	447e      	add	r6, pc
    2e16:	4630      	mov	r0, r6
    2e18:	f7ff e95e 	blx	20d8 <open@plt>
    2e1c:	2800      	cmp	r0, #0
    2e1e:	f8c9 0000 	str.w	r0, [r9]
    2e22:	da03      	bge.n	2e2c <main@@Base+0xc30>
    2e24:	493e      	ldr	r1, [pc, #248]	; (2f20 <main@@Base+0xd24>)
    2e26:	2002      	movs	r0, #2
    2e28:	4479      	add	r1, pc
    2e2a:	e00a      	b.n	2e42 <main@@Base+0xc46>
    2e2c:	f44f 71d2 	mov.w	r1, #420	; 0x1a4
    2e30:	f7ff e90a 	blx	2048 <fchmod@plt>
    2e34:	f1b0 3fff 	cmp.w	r0, #4294967295	; 0xffffffff
    2e38:	4680      	mov	r8, r0
    2e3a:	d106      	bne.n	2e4a <main@@Base+0xc4e>
    2e3c:	4939      	ldr	r1, [pc, #228]	; (2f24 <main@@Base+0xd28>)
    2e3e:	2002      	movs	r0, #2
    2e40:	4479      	add	r1, pc
    2e42:	4632      	mov	r2, r6
    2e44:	f001 f980 	bl	4148 <main@@Base+0x1f4c>
    2e48:	e057      	b.n	2efa <main@@Base+0xcfe>
    2e4a:	2100      	movs	r1, #0
    2e4c:	4668      	mov	r0, sp
    2e4e:	f7ff e9b8 	blx	21c0 <pps_encoder_initialize@plt>
    2e52:	2c02      	cmp	r4, #2
    2e54:	d120      	bne.n	2e98 <main@@Base+0xc9c>
    2e56:	b91f      	cbnz	r7, 2e60 <main@@Base+0xc64>
    2e58:	4933      	ldr	r1, [pc, #204]	; (2f28 <main@@Base+0xd2c>)
    2e5a:	4620      	mov	r0, r4
    2e5c:	4479      	add	r1, pc
    2e5e:	e00b      	b.n	2e78 <main@@Base+0xc7c>
    2e60:	f507 7180 	add.w	r1, r7, #256	; 0x100
    2e64:	4620      	mov	r0, r4
    2e66:	aa07      	add	r2, sp, #28
    2e68:	2310      	movs	r3, #16
    2e6a:	f7ff e8e8 	blx	203c <inet_ntop@plt>
    2e6e:	4606      	mov	r6, r0
    2e70:	b928      	cbnz	r0, 2e7e <main@@Base+0xc82>
    2e72:	492e      	ldr	r1, [pc, #184]	; (2f2c <main@@Base+0xd30>)
    2e74:	4620      	mov	r0, r4
    2e76:	4479      	add	r1, pc
    2e78:	f001 f966 	bl	4148 <main@@Base+0x1f4c>
    2e7c:	e035      	b.n	2eea <main@@Base+0xcee>
    2e7e:	492c      	ldr	r1, [pc, #176]	; (2f30 <main@@Base+0xd34>)
    2e80:	2201      	movs	r2, #1
    2e82:	4668      	mov	r0, sp
    2e84:	4479      	add	r1, pc
    2e86:	f7ff e8fe 	blx	2084 <pps_encoder_add_bool@plt>
    2e8a:	492a      	ldr	r1, [pc, #168]	; (2f34 <main@@Base+0xd38>)
    2e8c:	4668      	mov	r0, sp
    2e8e:	4632      	mov	r2, r6
    2e90:	4479      	add	r1, pc
    2e92:	f7ff e862 	blx	1f58 <pps_encoder_add_string@plt>
    2e96:	e00a      	b.n	2eae <main@@Base+0xcb2>
    2e98:	4927      	ldr	r1, [pc, #156]	; (2f38 <main@@Base+0xd3c>)
    2e9a:	4668      	mov	r0, sp
    2e9c:	2200      	movs	r2, #0
    2e9e:	4479      	add	r1, pc
    2ea0:	f7ff e8f0 	blx	2084 <pps_encoder_add_bool@plt>
    2ea4:	4925      	ldr	r1, [pc, #148]	; (2f3c <main@@Base+0xd40>)
    2ea6:	4668      	mov	r0, sp
    2ea8:	4479      	add	r1, pc
    2eaa:	f7ff e802 	blx	1eb0 <pps_encoder_delete_attribute@plt>
    2eae:	4668      	mov	r0, sp
    2eb0:	f7fe efda 	blx	1e68 <pps_encoder_buffer@plt>
    2eb4:	b1e0      	cbz	r0, 2ef0 <main@@Base+0xcf4>
    2eb6:	4668      	mov	r0, sp
    2eb8:	f7ff e87e 	blx	1fb8 <pps_encoder_length@plt>
    2ebc:	4b20      	ldr	r3, [pc, #128]	; (2f40 <main@@Base+0xd44>)
    2ebe:	447b      	add	r3, pc
    2ec0:	681e      	ldr	r6, [r3, #0]
    2ec2:	4604      	mov	r4, r0
    2ec4:	4668      	mov	r0, sp
    2ec6:	f7fe efd0 	blx	1e68 <pps_encoder_buffer@plt>
    2eca:	4622      	mov	r2, r4
    2ecc:	4601      	mov	r1, r0
    2ece:	4630      	mov	r0, r6
    2ed0:	f7ff e866 	blx	1fa0 <write@plt>
    2ed4:	42a0      	cmp	r0, r4
    2ed6:	d00b      	beq.n	2ef0 <main@@Base+0xcf4>
    2ed8:	4668      	mov	r0, sp
    2eda:	f7fe efc6 	blx	1e68 <pps_encoder_buffer@plt>
    2ede:	4919      	ldr	r1, [pc, #100]	; (2f44 <main@@Base+0xd48>)
    2ee0:	4479      	add	r1, pc
    2ee2:	4602      	mov	r2, r0
    2ee4:	2002      	movs	r0, #2
    2ee6:	f001 f92f 	bl	4148 <main@@Base+0x1f4c>
    2eea:	f04f 38ff 	mov.w	r8, #4294967295	; 0xffffffff
    2eee:	e004      	b.n	2efa <main@@Base+0xcfe>
    2ef0:	4668      	mov	r0, sp
    2ef2:	f04f 0800 	mov.w	r8, #0
    2ef6:	f7fe efb2 	blx	1e5c <pps_encoder_cleanup@plt>
    2efa:	9a0b      	ldr	r2, [sp, #44]	; 0x2c
    2efc:	4640      	mov	r0, r8
    2efe:	682b      	ldr	r3, [r5, #0]
    2f00:	429a      	cmp	r2, r3
    2f02:	d001      	beq.n	2f08 <main@@Base+0xd0c>
    2f04:	f7fe ef2a 	blx	1d5c <__stack_chk_fail@plt>
    2f08:	b00d      	add	sp, #52	; 0x34
    2f0a:	e8bd 83f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, pc}
    2f0e:	bf00      	nop
    2f10:	6210      	str	r0, [r2, #32]
    2f12:	0000      	movs	r0, r0
    2f14:	0258      	lsls	r0, r3, #9
    2f16:	0000      	movs	r0, r0
    2f18:	6488      	str	r0, [r1, #72]	; 0x48
    2f1a:	0000      	movs	r0, r0
    2f1c:	2bee      	cmp	r3, #238	; 0xee
    2f1e:	0000      	movs	r0, r0
    2f20:	2c0f      	cmp	r4, #15
    2f22:	0000      	movs	r0, r0
    2f24:	2c1b      	cmp	r4, #27
    2f26:	0000      	movs	r0, r0
    2f28:	2c21      	cmp	r4, #33	; 0x21
    2f2a:	0000      	movs	r0, r0
    2f2c:	2c29      	cmp	r4, #41	; 0x29
    2f2e:	0000      	movs	r0, r0
    2f30:	2c45      	cmp	r4, #69	; 0x45
    2f32:	0000      	movs	r0, r0
    2f34:	2c46      	cmp	r4, #70	; 0x46
    2f36:	0000      	movs	r0, r0
    2f38:	2c2b      	cmp	r4, #43	; 0x2b
    2f3a:	0000      	movs	r0, r0
    2f3c:	2c31      	cmp	r4, #49	; 0x31
    2f3e:	0000      	movs	r0, r0
    2f40:	63c2      	str	r2, [r0, #60]	; 0x3c
    2f42:	0000      	movs	r0, r0
    2f44:	2c04      	cmp	r4, #4
    2f46:	0000      	movs	r0, r0
    2f48:	4bb4      	ldr	r3, [pc, #720]	; (321c <main@@Base+0x1020>)
    2f4a:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
    2f4e:	b0ea      	sub	sp, #424	; 0x1a8
    2f50:	4ab3      	ldr	r2, [pc, #716]	; (3220 <main@@Base+0x1024>)
    2f52:	447b      	add	r3, pc
    2f54:	af02      	add	r7, sp, #8
    2f56:	4604      	mov	r4, r0
    2f58:	589d      	ldr	r5, [r3, r2]
    2f5a:	4ab2      	ldr	r2, [pc, #712]	; (3224 <main@@Base+0x1028>)
    2f5c:	682b      	ldr	r3, [r5, #0]
    2f5e:	447a      	add	r2, pc
    2f60:	61fa      	str	r2, [r7, #28]
    2f62:	4ab1      	ldr	r2, [pc, #708]	; (3228 <main@@Base+0x102c>)
    2f64:	f8c7 319c 	str.w	r3, [r7, #412]	; 0x19c
    2f68:	4bb0      	ldr	r3, [pc, #704]	; (322c <main@@Base+0x1030>)
    2f6a:	447a      	add	r2, pc
    2f6c:	627a      	str	r2, [r7, #36]	; 0x24
    2f6e:	447b      	add	r3, pc
    2f70:	60bb      	str	r3, [r7, #8]
    2f72:	4baf      	ldr	r3, [pc, #700]	; (3230 <main@@Base+0x1034>)
    2f74:	4aaf      	ldr	r2, [pc, #700]	; (3234 <main@@Base+0x1038>)
    2f76:	447b      	add	r3, pc
    2f78:	60fb      	str	r3, [r7, #12]
    2f7a:	4baf      	ldr	r3, [pc, #700]	; (3238 <main@@Base+0x103c>)
    2f7c:	447a      	add	r2, pc
    2f7e:	62fa      	str	r2, [r7, #44]	; 0x2c
    2f80:	447b      	add	r3, pc
    2f82:	613b      	str	r3, [r7, #16]
    2f84:	4bad      	ldr	r3, [pc, #692]	; (323c <main@@Base+0x1040>)
    2f86:	4aae      	ldr	r2, [pc, #696]	; (3240 <main@@Base+0x1044>)
    2f88:	447b      	add	r3, pc
    2f8a:	617b      	str	r3, [r7, #20]
    2f8c:	4bad      	ldr	r3, [pc, #692]	; (3244 <main@@Base+0x1048>)
    2f8e:	447a      	add	r2, pc
    2f90:	637a      	str	r2, [r7, #52]	; 0x34
    2f92:	447b      	add	r3, pc
    2f94:	61bb      	str	r3, [r7, #24]
    2f96:	623b      	str	r3, [r7, #32]
    2f98:	62bb      	str	r3, [r7, #40]	; 0x28
    2f9a:	633b      	str	r3, [r7, #48]	; 0x30
    2f9c:	63bb      	str	r3, [r7, #56]	; 0x38
    2f9e:	f8d0 30f0 	ldr.w	r3, [r0, #240]	; 0xf0
    2fa2:	b113      	cbz	r3, 2faa <main@@Base+0xdae>
    2fa4:	4aa8      	ldr	r2, [pc, #672]	; (3248 <main@@Base+0x104c>)
    2fa6:	447a      	add	r2, pc
    2fa8:	e001      	b.n	2fae <main@@Base+0xdb2>
    2faa:	4aa8      	ldr	r2, [pc, #672]	; (324c <main@@Base+0x1050>)
    2fac:	447a      	add	r2, pc
    2fae:	63fa      	str	r2, [r7, #60]	; 0x3c
    2fb0:	4aa7      	ldr	r2, [pc, #668]	; (3250 <main@@Base+0x1054>)
    2fb2:	447a      	add	r2, pc
    2fb4:	643a      	str	r2, [r7, #64]	; 0x40
    2fb6:	b113      	cbz	r3, 2fbe <main@@Base+0xdc2>
    2fb8:	4aa6      	ldr	r2, [pc, #664]	; (3254 <main@@Base+0x1058>)
    2fba:	447a      	add	r2, pc
    2fbc:	e001      	b.n	2fc2 <main@@Base+0xdc6>
    2fbe:	4aa6      	ldr	r2, [pc, #664]	; (3258 <main@@Base+0x105c>)
    2fc0:	447a      	add	r2, pc
    2fc2:	647a      	str	r2, [r7, #68]	; 0x44
    2fc4:	4aa5      	ldr	r2, [pc, #660]	; (325c <main@@Base+0x1060>)
    2fc6:	447a      	add	r2, pc
    2fc8:	64ba      	str	r2, [r7, #72]	; 0x48
    2fca:	b113      	cbz	r3, 2fd2 <main@@Base+0xdd6>
    2fcc:	4aa4      	ldr	r2, [pc, #656]	; (3260 <main@@Base+0x1064>)
    2fce:	447a      	add	r2, pc
    2fd0:	e001      	b.n	2fd6 <main@@Base+0xdda>
    2fd2:	4aa4      	ldr	r2, [pc, #656]	; (3264 <main@@Base+0x1068>)
    2fd4:	447a      	add	r2, pc
    2fd6:	64fa      	str	r2, [r7, #76]	; 0x4c
    2fd8:	4aa3      	ldr	r2, [pc, #652]	; (3268 <main@@Base+0x106c>)
    2fda:	447a      	add	r2, pc
    2fdc:	653a      	str	r2, [r7, #80]	; 0x50
    2fde:	4aa3      	ldr	r2, [pc, #652]	; (326c <main@@Base+0x1070>)
    2fe0:	447a      	add	r2, pc
    2fe2:	657a      	str	r2, [r7, #84]	; 0x54
    2fe4:	2200      	movs	r2, #0
    2fe6:	65ba      	str	r2, [r7, #88]	; 0x58
    2fe8:	b143      	cbz	r3, 2ffc <main@@Base+0xe00>
    2fea:	48a1      	ldr	r0, [pc, #644]	; (3270 <main@@Base+0x1074>)
    2fec:	49a1      	ldr	r1, [pc, #644]	; (3274 <main@@Base+0x1078>)
    2fee:	4478      	add	r0, pc
    2ff0:	4479      	add	r1, pc
    2ff2:	f7ff fd49 	bl	2a88 <main@@Base+0x88c>
    2ff6:	2800      	cmp	r0, #0
    2ff8:	f040 80fc 	bne.w	31f4 <main@@Base+0xff8>
    2ffc:	1d38      	adds	r0, r7, #4
    2ffe:	f7fe edb8 	blx	1b70 <posix_spawnattr_init@plt>
    3002:	4985      	ldr	r1, [pc, #532]	; (3218 <main@@Base+0x101c>)
    3004:	1d38      	adds	r0, r7, #4
    3006:	f7fe ee4e 	blx	1ca4 <posix_spawnattr_setxflags@plt>
    300a:	2100      	movs	r1, #0
    300c:	1d38      	adds	r0, r7, #4
    300e:	f7ff e8b4 	blx	2178 <posix_spawnattr_setpgroup@plt>
    3012:	2100      	movs	r1, #0
    3014:	1d38      	adds	r0, r7, #4
    3016:	460a      	mov	r2, r1
    3018:	f7fe ee82 	blx	1d20 <posix_spawnattr_setcred@plt>
    301c:	2000      	movs	r0, #0
    301e:	f107 0284 	add.w	r2, r7, #132	; 0x84
    3022:	4601      	mov	r1, r0
    3024:	f7fe edbc 	blx	1ba0 <pthread_sigmask@plt>
    3028:	f107 0184 	add.w	r1, r7, #132	; 0x84
    302c:	1d38      	adds	r0, r7, #4
    302e:	f7fe ee16 	blx	1c5c <posix_spawnattr_setsigmask@plt>
    3032:	f107 0308 	add.w	r3, r7, #8
    3036:	2200      	movs	r2, #0
    3038:	9300      	str	r3, [sp, #0]
    303a:	9201      	str	r2, [sp, #4]
    303c:	f104 00f8 	add.w	r0, r4, #248	; 0xf8
    3040:	68b9      	ldr	r1, [r7, #8]
    3042:	1d3b      	adds	r3, r7, #4
    3044:	f7fe eea8 	blx	1d98 <posix_spawn@plt>
    3048:	4606      	mov	r6, r0
    304a:	1d38      	adds	r0, r7, #4
    304c:	f7fe ef96 	blx	1f7c <posix_spawnattr_destroy@plt>
    3050:	2e00      	cmp	r6, #0
    3052:	f040 80cf 	bne.w	31f4 <main@@Base+0xff8>
    3056:	4988      	ldr	r1, [pc, #544]	; (3278 <main@@Base+0x107c>)
    3058:	2206      	movs	r2, #6
    305a:	f107 008c 	add.w	r0, r7, #140	; 0x8c
    305e:	4479      	add	r1, pc
    3060:	f501 7180 	add.w	r1, r1, #256	; 0x100
    3064:	f7fe ee50 	blx	1d08 <memcpy@plt+0x4>
    3068:	4631      	mov	r1, r6
    306a:	22fa      	movs	r2, #250	; 0xfa
    306c:	f107 0092 	add.w	r0, r7, #146	; 0x92
    3070:	f7fe eeb2 	blx	1dd8 <memset@plt+0x4>
    3074:	2310      	movs	r3, #16
    3076:	f504 7180 	add.w	r1, r4, #256	; 0x100
    307a:	f507 72c6 	add.w	r2, r7, #396	; 0x18c
    307e:	2002      	movs	r0, #2
    3080:	f7fe efdc 	blx	203c <inet_ntop@plt>
    3084:	f44f 7280 	mov.w	r2, #256	; 0x100
    3088:	4601      	mov	r1, r0
    308a:	f107 008c 	add.w	r0, r7, #140	; 0x8c
    308e:	f7fe edec 	blx	1c68 <strlcat@plt>
    3092:	f8d4 30f0 	ldr.w	r3, [r4, #240]	; 0xf0
    3096:	b14b      	cbz	r3, 30ac <main@@Base+0xeb0>
    3098:	f104 01f4 	add.w	r1, r4, #244	; 0xf4
    309c:	f107 008c 	add.w	r0, r7, #140	; 0x8c
    30a0:	f7ff fe20 	bl	2ce4 <main@@Base+0xae8>
    30a4:	2800      	cmp	r0, #0
    30a6:	f040 80a7 	bne.w	31f8 <main@@Base+0xffc>
    30aa:	e099      	b.n	31e0 <main@@Base+0xfe4>
    30ac:	f7fe ee4a 	blx	1d44 <fork@plt>
    30b0:	1c42      	adds	r2, r0, #1
    30b2:	f8c4 00f4 	str.w	r0, [r4, #244]	; 0xf4
    30b6:	d105      	bne.n	30c4 <main@@Base+0xec8>
    30b8:	4970      	ldr	r1, [pc, #448]	; (327c <main@@Base+0x1080>)
    30ba:	2002      	movs	r0, #2
    30bc:	4479      	add	r1, pc
    30be:	f001 f843 	bl	4148 <main@@Base+0x1f4c>
    30c2:	e099      	b.n	31f8 <main@@Base+0xffc>
    30c4:	2800      	cmp	r0, #0
    30c6:	f040 808b 	bne.w	31e0 <main@@Base+0xfe4>
    30ca:	4e6d      	ldr	r6, [pc, #436]	; (3280 <main@@Base+0x1084>)
    30cc:	447e      	add	r6, pc
    30ce:	4630      	mov	r0, r6
    30d0:	f7fe efde 	blx	2090 <getpwnam@plt>
    30d4:	4604      	mov	r4, r0
    30d6:	2800      	cmp	r0, #0
    30d8:	f000 8090 	beq.w	31fc <main@@Base+0x1000>
    30dc:	6883      	ldr	r3, [r0, #8]
    30de:	2b00      	cmp	r3, #0
    30e0:	f000 808c 	beq.w	31fc <main@@Base+0x1000>
    30e4:	4630      	mov	r0, r6
    30e6:	68e1      	ldr	r1, [r4, #12]
    30e8:	f7fe eeee 	blx	1ec8 <initgroups@plt>
    30ec:	3001      	adds	r0, #1
    30ee:	f000 8085 	beq.w	31fc <main@@Base+0x1000>
    30f2:	68e0      	ldr	r0, [r4, #12]
    30f4:	f7ff e82e 	blx	2154 <setgid@plt>
    30f8:	3001      	adds	r0, #1
    30fa:	d07f      	beq.n	31fc <main@@Base+0x1000>
    30fc:	68e0      	ldr	r0, [r4, #12]
    30fe:	f7fe eda8 	blx	1c50 <setegid@plt>
    3102:	3001      	adds	r0, #1
    3104:	d07a      	beq.n	31fc <main@@Base+0x1000>
    3106:	485f      	ldr	r0, [pc, #380]	; (3284 <main@@Base+0x1088>)
    3108:	495f      	ldr	r1, [pc, #380]	; (3288 <main@@Base+0x108c>)
    310a:	4478      	add	r0, pc
    310c:	4479      	add	r1, pc
    310e:	f7ff faa5 	bl	265c <main@@Base+0x460>
    3112:	2801      	cmp	r0, #1
    3114:	d126      	bne.n	3164 <main@@Base+0xf68>
    3116:	2004      	movs	r0, #4
    3118:	466e      	mov	r6, sp
    311a:	f7fe eddc 	blx	1cd4 <sysconf@plt>
    311e:	0080      	lsls	r0, r0, #2
    3120:	300e      	adds	r0, #14
    3122:	f020 0007 	bic.w	r0, r0, #7
    3126:	ebad 0d00 	sub.w	sp, sp, r0
    312a:	2004      	movs	r0, #4
    312c:	f10d 0808 	add.w	r8, sp, #8
    3130:	f7fe edd0 	blx	1cd4 <sysconf@plt>
    3134:	4641      	mov	r1, r8
    3136:	f7fe efbe 	blx	20b4 <getgroups@plt>
    313a:	f44f 6396 	mov.w	r3, #1200	; 0x4b0
    313e:	4641      	mov	r1, r8
    3140:	f848 3020 	str.w	r3, [r8, r0, lsl #2]
    3144:	3001      	adds	r0, #1
    3146:	f7fe ef32 	blx	1fac <setgroups@plt>
    314a:	2800      	cmp	r0, #0
    314c:	da08      	bge.n	3160 <main@@Base+0xf64>
    314e:	f7fe ed60 	blx	1c10 <__get_errno_ptr@plt>
    3152:	494e      	ldr	r1, [pc, #312]	; (328c <main@@Base+0x1090>)
    3154:	4479      	add	r1, pc
    3156:	4603      	mov	r3, r0
    3158:	2002      	movs	r0, #2
    315a:	681a      	ldr	r2, [r3, #0]
    315c:	f000 fff4 	bl	4148 <main@@Base+0x1f4c>
    3160:	46b5      	mov	sp, r6
    3162:	e004      	b.n	316e <main@@Base+0xf72>
    3164:	494a      	ldr	r1, [pc, #296]	; (3290 <main@@Base+0x1094>)
    3166:	2003      	movs	r0, #3
    3168:	4479      	add	r1, pc
    316a:	f000 ffed 	bl	4148 <main@@Base+0x1f4c>
    316e:	68a0      	ldr	r0, [r4, #8]
    3170:	f7fe edee 	blx	1d50 <setuid@plt>
    3174:	3001      	adds	r0, #1
    3176:	d041      	beq.n	31fc <main@@Base+0x1000>
    3178:	68a0      	ldr	r0, [r4, #8]
    317a:	f7fe eda6 	blx	1cc8 <seteuid@plt>
    317e:	2800      	cmp	r0, #0
    3180:	d13c      	bne.n	31fc <main@@Base+0x1000>
    3182:	f107 015c 	add.w	r1, r7, #92	; 0x5c
    3186:	f7ff e810 	blx	21a8 <sched_getparam@plt>
    318a:	4604      	mov	r4, r0
    318c:	b9a0      	cbnz	r0, 31b8 <main@@Base+0xfbc>
    318e:	230b      	movs	r3, #11
    3190:	65fb      	str	r3, [r7, #92]	; 0x5c
    3192:	f7fe ed94 	blx	1cbc <sched_getscheduler@plt>
    3196:	1c43      	adds	r3, r0, #1
    3198:	4601      	mov	r1, r0
    319a:	d009      	beq.n	31b0 <main@@Base+0xfb4>
    319c:	4620      	mov	r0, r4
    319e:	f107 025c 	add.w	r2, r7, #92	; 0x5c
    31a2:	f7fe efe4 	blx	216c <sched_setscheduler@plt>
    31a6:	b160      	cbz	r0, 31c2 <main@@Base+0xfc6>
    31a8:	493a      	ldr	r1, [pc, #232]	; (3294 <main@@Base+0x1098>)
    31aa:	2003      	movs	r0, #3
    31ac:	4479      	add	r1, pc
    31ae:	e006      	b.n	31be <main@@Base+0xfc2>
    31b0:	4939      	ldr	r1, [pc, #228]	; (3298 <main@@Base+0x109c>)
    31b2:	2003      	movs	r0, #3
    31b4:	4479      	add	r1, pc
    31b6:	e002      	b.n	31be <main@@Base+0xfc2>
    31b8:	4938      	ldr	r1, [pc, #224]	; (329c <main@@Base+0x10a0>)
    31ba:	2003      	movs	r0, #3
    31bc:	4479      	add	r1, pc
    31be:	f000 ffc3 	bl	4148 <main@@Base+0x1f4c>
    31c2:	4837      	ldr	r0, [pc, #220]	; (32a0 <main@@Base+0x10a4>)
    31c4:	f107 028c 	add.w	r2, r7, #140	; 0x8c
    31c8:	4936      	ldr	r1, [pc, #216]	; (32a4 <main@@Base+0x10a8>)
    31ca:	2300      	movs	r3, #0
    31cc:	4478      	add	r0, pc
    31ce:	4479      	add	r1, pc
    31d0:	f7fe ee5c 	blx	1e8c <execl@plt>
    31d4:	4934      	ldr	r1, [pc, #208]	; (32a8 <main@@Base+0x10ac>)
    31d6:	2002      	movs	r0, #2
    31d8:	4479      	add	r1, pc
    31da:	f000 ffb5 	bl	4148 <main@@Base+0x1f4c>
    31de:	e00d      	b.n	31fc <main@@Base+0x1000>
    31e0:	2002      	movs	r0, #2
    31e2:	4621      	mov	r1, r4
    31e4:	f7ff fdfe 	bl	2de4 <main@@Base+0xbe8>
    31e8:	f1b0 3fff 	cmp.w	r0, #4294967295	; 0xffffffff
    31ec:	bf0c      	ite	eq
    31ee:	2014      	moveq	r0, #20
    31f0:	2000      	movne	r0, #0
    31f2:	e004      	b.n	31fe <main@@Base+0x1002>
    31f4:	2004      	movs	r0, #4
    31f6:	e002      	b.n	31fe <main@@Base+0x1002>
    31f8:	2003      	movs	r0, #3
    31fa:	e000      	b.n	31fe <main@@Base+0x1002>
    31fc:	2001      	movs	r0, #1
    31fe:	f8d7 219c 	ldr.w	r2, [r7, #412]	; 0x19c
    3202:	682b      	ldr	r3, [r5, #0]
    3204:	429a      	cmp	r2, r3
    3206:	d001      	beq.n	320c <main@@Base+0x1010>
    3208:	f7fe eda8 	blx	1d5c <__stack_chk_fail@plt>
    320c:	f507 77d0 	add.w	r7, r7, #416	; 0x1a0
    3210:	46bd      	mov	sp, r7
    3212:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
    3216:	bf00      	nop
    3218:	0003      	movs	r3, r0
    321a:	0008      	movs	r0, r1
    321c:	60aa      	str	r2, [r5, #8]
    321e:	0000      	movs	r0, r0
    3220:	0258      	lsls	r0, r3, #9
    3222:	0000      	movs	r0, r0
    3224:	2c7f      	cmp	r4, #127	; 0x7f
    3226:	0000      	movs	r0, r0
    3228:	2c8f      	cmp	r4, #143	; 0x8f
    322a:	0000      	movs	r0, r0
    322c:	2c4d      	cmp	r4, #77	; 0x4d
    322e:	0000      	movs	r0, r0
    3230:	2c54      	cmp	r4, #84	; 0x54
    3232:	0000      	movs	r0, r0
    3234:	2c97      	cmp	r4, #151	; 0x97
    3236:	0000      	movs	r0, r0
    3238:	2c4d      	cmp	r4, #77	; 0x4d
    323a:	0000      	movs	r0, r0
    323c:	2c48      	cmp	r4, #72	; 0x48
    323e:	0000      	movs	r0, r0
    3240:	2c90      	cmp	r4, #144	; 0x90
    3242:	0000      	movs	r0, r0
    3244:	2c48      	cmp	r4, #72	; 0x48
    3246:	0000      	movs	r0, r0
    3248:	2b5c      	cmp	r3, #92	; 0x5c
    324a:	0000      	movs	r0, r0
    324c:	2b8e      	cmp	r3, #142	; 0x8e
    324e:	0000      	movs	r0, r0
    3250:	2c28      	cmp	r4, #40	; 0x28
    3252:	0000      	movs	r0, r0
    3254:	2bbb      	cmp	r3, #187	; 0xbb
    3256:	0000      	movs	r0, r0
    3258:	2bc5      	cmp	r3, #197	; 0xc5
    325a:	0000      	movs	r0, r0
    325c:	2c14      	cmp	r4, #20
    325e:	0000      	movs	r0, r0
    3260:	2bca      	cmp	r3, #202	; 0xca
    3262:	0000      	movs	r0, r0
    3264:	2bd8      	cmp	r3, #216	; 0xd8
    3266:	0000      	movs	r0, r0
    3268:	2c00      	cmp	r4, #0
    326a:	0000      	movs	r0, r0
    326c:	2c60      	cmp	r4, #96	; 0x60
    326e:	0000      	movs	r0, r0
    3270:	29ca      	cmp	r1, #202	; 0xca
    3272:	0000      	movs	r0, r0
    3274:	2c78      	cmp	r4, #120	; 0x78
    3276:	0000      	movs	r0, r0
    3278:	26c5      	movs	r6, #197	; 0xc5
    327a:	0000      	movs	r0, r0
    327c:	2bb5      	cmp	r3, #181	; 0xb5
    327e:	0000      	movs	r0, r0
    3280:	2ac4      	cmp	r2, #196	; 0xc4
    3282:	0000      	movs	r0, r0
    3284:	2b84      	cmp	r3, #132	; 0x84
    3286:	0000      	movs	r0, r0
    3288:	2bb6      	cmp	r3, #182	; 0xb6
    328a:	0000      	movs	r0, r0
    328c:	2b8e      	cmp	r3, #142	; 0x8e
    328e:	0000      	movs	r0, r0
    3290:	2bb1      	cmp	r3, #177	; 0xb1
    3292:	0000      	movs	r0, r0
    3294:	2b90      	cmp	r3, #144	; 0x90
    3296:	0000      	movs	r0, r0
    3298:	2ba9      	cmp	r3, #169	; 0xa9
    329a:	0000      	movs	r0, r0
    329c:	2bcf      	cmp	r3, #207	; 0xcf
    329e:	0000      	movs	r0, r0
    32a0:	2826      	cmp	r0, #38	; 0x26
    32a2:	0000      	movs	r0, r0
    32a4:	2bfe      	cmp	r3, #254	; 0xfe
    32a6:	0000      	movs	r0, r0
    32a8:	2be5      	cmp	r3, #229	; 0xe5
    32aa:	0000      	movs	r0, r0
    32ac:	b510      	push	{r4, lr}
    32ae:	4604      	mov	r4, r0
    32b0:	f7ff fd66 	bl	2d80 <main@@Base+0xb84>
    32b4:	2001      	movs	r0, #1
    32b6:	2100      	movs	r1, #0
    32b8:	f7ff fd94 	bl	2de4 <main@@Base+0xbe8>
    32bc:	68a0      	ldr	r0, [r4, #8]
    32be:	2800      	cmp	r0, #0
    32c0:	dd01      	ble.n	32c6 <main@@Base+0x10ca>
    32c2:	f7fe ec7c 	blx	1bbc <close@plt+0x4>
    32c6:	4620      	mov	r0, r4
    32c8:	f7ff fa7c 	bl	27c4 <main@@Base+0x5c8>
    32cc:	200a      	movs	r0, #10
    32ce:	e8bd 4010 	ldmia.w	sp!, {r4, lr}
    32d2:	f7fe bf19 	b.w	2108 <sleep@plt>
    32d6:	4b0d      	ldr	r3, [pc, #52]	; (330c <main@@Base+0x1110>)
    32d8:	4a0d      	ldr	r2, [pc, #52]	; (3310 <main@@Base+0x1114>)
    32da:	447b      	add	r3, pc
    32dc:	b510      	push	{r4, lr}
    32de:	589c      	ldr	r4, [r3, r2]
    32e0:	4620      	mov	r0, r4
    32e2:	f7ff ffe3 	bl	32ac <main@@Base+0x10b0>
    32e6:	4b0b      	ldr	r3, [pc, #44]	; (3314 <main@@Base+0x1118>)
    32e8:	447b      	add	r3, pc
    32ea:	6818      	ldr	r0, [r3, #0]
    32ec:	1c41      	adds	r1, r0, #1
    32ee:	d005      	beq.n	32fc <main@@Base+0x1100>
    32f0:	f7fe ec64 	blx	1bbc <close@plt+0x4>
    32f4:	4808      	ldr	r0, [pc, #32]	; (3318 <main@@Base+0x111c>)
    32f6:	4478      	add	r0, pc
    32f8:	f7fe ecda 	blx	1cb0 <unlink@plt>
    32fc:	f104 0014 	add.w	r0, r4, #20
    3300:	f7fe eeae 	blx	2060 <DisposeEncryptionChallenge@plt>
    3304:	2000      	movs	r0, #0
    3306:	f7fe ec1c 	blx	1b40 <exit@plt>
    330a:	bf00      	nop
    330c:	5d22      	ldrb	r2, [r4, r4]
    330e:	0000      	movs	r0, r0
    3310:	0244      	lsls	r4, r0, #9
    3312:	0000      	movs	r0, r0
    3314:	5f98      	ldrsh	r0, [r3, r6]
    3316:	0000      	movs	r0, r0
    3318:	270c      	movs	r7, #12
    331a:	0000      	movs	r0, r0
    331c:	4bca      	ldr	r3, [pc, #808]	; (3648 <main@@Base+0x144c>)
    331e:	4acb      	ldr	r2, [pc, #812]	; (364c <main@@Base+0x1450>)
    3320:	447b      	add	r3, pc
    3322:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
    3326:	f5ad 5d8a 	sub.w	sp, sp, #4416	; 0x1140
    332a:	589e      	ldr	r6, [r3, r2]
    332c:	b08d      	sub	sp, #52	; 0x34
    332e:	f50d 518a 	add.w	r1, sp, #4416	; 0x1140
    3332:	4604      	mov	r4, r0
    3334:	312c      	adds	r1, #44	; 0x2c
    3336:	f44f 5280 	mov.w	r2, #4096	; 0x1000
    333a:	6833      	ldr	r3, [r6, #0]
    333c:	a815      	add	r0, sp, #84	; 0x54
    333e:	600b      	str	r3, [r1, #0]
    3340:	2100      	movs	r1, #0
    3342:	f7fe ed4a 	blx	1dd8 <memset@plt+0x4>
    3346:	a90e      	add	r1, sp, #56	; 0x38
    3348:	f44f 5380 	mov.w	r3, #4096	; 0x1000
    334c:	4620      	mov	r0, r4
    334e:	aa15      	add	r2, sp, #84	; 0x54
    3350:	f000 fd0c 	bl	3d6c <main@@Base+0x1b70>
    3354:	2100      	movs	r1, #0
    3356:	9607      	str	r6, [sp, #28]
    3358:	f100 0309 	add.w	r3, r0, #9
    335c:	4680      	mov	r8, r0
    335e:	2b01      	cmp	r3, #1
    3360:	a815      	add	r0, sp, #84	; 0x54
    3362:	f240 808c 	bls.w	347e <main@@Base+0x1282>
    3366:	f1b8 0f00 	cmp.w	r8, #0
    336a:	da14      	bge.n	3396 <main@@Base+0x119a>
    336c:	4640      	mov	r0, r8
    336e:	f04f 0800 	mov.w	r8, #0
    3372:	f000 fa8c 	bl	388e <main@@Base+0x1692>
    3376:	49b6      	ldr	r1, [pc, #728]	; (3650 <main@@Base+0x1454>)
    3378:	4479      	add	r1, pc
    337a:	4602      	mov	r2, r0
    337c:	2002      	movs	r0, #2
    337e:	f000 fee3 	bl	4148 <main@@Base+0x1f4c>
    3382:	4620      	mov	r0, r4
    3384:	f7ff ff92 	bl	32ac <main@@Base+0x10b0>
    3388:	a815      	add	r0, sp, #84	; 0x54
    338a:	2100      	movs	r1, #0
    338c:	f44f 5280 	mov.w	r2, #4096	; 0x1000
    3390:	f7fe ed22 	blx	1dd8 <memset@plt+0x4>
    3394:	e148      	b.n	3628 <main@@Base+0x142c>
    3396:	f8bd 303c 	ldrh.w	r3, [sp, #60]	; 0x3c
    339a:	3b03      	subs	r3, #3
    339c:	2b09      	cmp	r3, #9
    339e:	f200 8119 	bhi.w	35d4 <main@@Base+0x13d8>
    33a2:	e8df f013 	tbh	[pc, r3, lsl #1]
    33a6:	000a      	movs	r2, r1
    33a8:	0117      	lsls	r7, r2, #4
    33aa:	0071      	lsls	r1, r6, #1
    33ac:	0105      	lsls	r5, r0, #4
    33ae:	00d8      	lsls	r0, r3, #3
    33b0:	0090      	lsls	r0, r2, #2
    33b2:	0117      	lsls	r7, r2, #4
    33b4:	00b7      	lsls	r7, r6, #2
    33b6:	00f9      	lsls	r1, r7, #3
    33b8:	010e      	lsls	r6, r1, #4
    33ba:	f44f 738c 	mov.w	r3, #280	; 0x118
    33be:	9314      	str	r3, [sp, #80]	; 0x50
    33c0:	6923      	ldr	r3, [r4, #16]
    33c2:	2b02      	cmp	r3, #2
    33c4:	f040 8106 	bne.w	35d4 <main@@Base+0x13d8>
    33c8:	f8bd 6040 	ldrh.w	r6, [sp, #64]	; 0x40
    33cc:	f04f 0901 	mov.w	r9, #1
    33d0:	bb2e      	cbnz	r6, 341e <main@@Base+0x1222>
    33d2:	f8c4 90f0 	str.w	r9, [r4, #240]	; 0xf0
    33d6:	f7fe ec10 	blx	1bf8 <RTAS_LoadQconnKeyExV2@plt>
    33da:	b978      	cbnz	r0, 33fc <main@@Base+0x1200>
    33dc:	499d      	ldr	r1, [pc, #628]	; (3654 <main@@Base+0x1458>)
    33de:	2003      	movs	r0, #3
    33e0:	4f9d      	ldr	r7, [pc, #628]	; (3658 <main@@Base+0x145c>)
    33e2:	f04f 0b0a 	mov.w	fp, #10
    33e6:	f8df 8274 	ldr.w	r8, [pc, #628]	; 365c <main@@Base+0x1460>
    33ea:	4479      	add	r1, pc
    33ec:	447f      	add	r7, pc
    33ee:	f000 feab 	bl	4148 <main@@Base+0x1f4c>
    33f2:	44f8      	add	r8, pc
    33f4:	2680      	movs	r6, #128	; 0x80
    33f6:	f507 7700 	add.w	r7, r7, #512	; 0x200
    33fa:	e019      	b.n	3430 <main@@Base+0x1234>
    33fc:	4998      	ldr	r1, [pc, #608]	; (3660 <main@@Base+0x1464>)
    33fe:	4680      	mov	r8, r0
    3400:	4642      	mov	r2, r8
    3402:	2005      	movs	r0, #5
    3404:	4479      	add	r1, pc
    3406:	f108 0720 	add.w	r7, r8, #32
    340a:	f000 fe9d 	bl	4148 <main@@Base+0x1f4c>
    340e:	4640      	mov	r0, r8
    3410:	f7fe ee9a 	blx	2148 <strlen@plt>
    3414:	2680      	movs	r6, #128	; 0x80
    3416:	f8d8 90a4 	ldr.w	r9, [r8, #164]	; 0xa4
    341a:	4683      	mov	fp, r0
    341c:	e008      	b.n	3430 <main@@Base+0x1234>
    341e:	f8df 8244 	ldr.w	r8, [pc, #580]	; 3664 <main@@Base+0x1468>
    3422:	f04f 0b0a 	mov.w	fp, #10
    3426:	9f11      	ldr	r7, [sp, #68]	; 0x44
    3428:	2300      	movs	r3, #0
    342a:	44f8      	add	r8, pc
    342c:	f8c4 30f0 	str.w	r3, [r4, #240]	; 0xf0
    3430:	4620      	mov	r0, r4
    3432:	f7ff f9f0 	bl	2816 <main@@Base+0x61a>
    3436:	4605      	mov	r5, r0
    3438:	b108      	cbz	r0, 343e <main@@Base+0x1242>
    343a:	4606      	mov	r6, r0
    343c:	e0c8      	b.n	35d0 <main@@Base+0x13d4>
    343e:	9601      	str	r6, [sp, #4]
    3440:	4641      	mov	r1, r8
    3442:	f104 0014 	add.w	r0, r4, #20
    3446:	f50d 5682 	add.w	r6, sp, #4160	; 0x1040
    344a:	465a      	mov	r2, fp
    344c:	464b      	mov	r3, r9
    344e:	9700      	str	r7, [sp, #0]
    3450:	3614      	adds	r6, #20
    3452:	f10d 0a50 	add.w	sl, sp, #80	; 0x50
    3456:	9602      	str	r6, [sp, #8]
    3458:	f8cd a00c 	str.w	sl, [sp, #12]
    345c:	2703      	movs	r7, #3
    345e:	9704      	str	r7, [sp, #16]
    3460:	f7fe ede6 	blx	2030 <GetEncryptionChallengeEx@plt>
    3464:	4680      	mov	r8, r0
    3466:	2800      	cmp	r0, #0
    3468:	f040 80b0 	bne.w	35cc <main@@Base+0x13d0>
    346c:	4631      	mov	r1, r6
    346e:	6127      	str	r7, [r4, #16]
    3470:	4620      	mov	r0, r4
    3472:	f8da 2000 	ldr.w	r2, [sl]
    3476:	f000 fa59 	bl	392c <main@@Base+0x1730>
    347a:	a815      	add	r0, sp, #84	; 0x54
    347c:	4641      	mov	r1, r8
    347e:	f44f 5280 	mov.w	r2, #4096	; 0x1000
    3482:	f7fe ecaa 	blx	1dd8 <memset@plt+0x4>
    3486:	e0cf      	b.n	3628 <main@@Base+0x142c>
    3488:	6927      	ldr	r7, [r4, #16]
    348a:	2f03      	cmp	r7, #3
    348c:	f040 80a2 	bne.w	35d4 <main@@Base+0x13d8>
    3490:	2602      	movs	r6, #2
    3492:	f104 0014 	add.w	r0, r4, #20
    3496:	83a6      	strh	r6, [r4, #28]
    3498:	aa11      	add	r2, sp, #68	; 0x44
    349a:	21dc      	movs	r1, #220	; 0xdc
    349c:	f7fe ecb4 	blx	1e08 <VerifyEncryptionChallenge@plt>
    34a0:	83a7      	strh	r7, [r4, #28]
    34a2:	4605      	mov	r5, r0
    34a4:	2800      	cmp	r0, #0
    34a6:	f040 8093 	bne.w	35d0 <main@@Base+0x13d4>
    34aa:	f8d4 30f0 	ldr.w	r3, [r4, #240]	; 0xf0
    34ae:	b13b      	cbz	r3, 34c0 <main@@Base+0x12c4>
    34b0:	f001 f9c2 	bl	4838 <main@@Base+0x263c>
    34b4:	300a      	adds	r0, #10
    34b6:	d103      	bne.n	34c0 <main@@Base+0x12c4>
    34b8:	2306      	movs	r3, #6
    34ba:	2611      	movs	r6, #17
    34bc:	6123      	str	r3, [r4, #16]
    34be:	e08e      	b.n	35de <main@@Base+0x13e2>
    34c0:	2304      	movs	r3, #4
    34c2:	6123      	str	r3, [r4, #16]
    34c4:	e080      	b.n	35c8 <main@@Base+0x13cc>
    34c6:	6923      	ldr	r3, [r4, #16]
    34c8:	2500      	movs	r5, #0
    34ca:	9514      	str	r5, [sp, #80]	; 0x50
    34cc:	2b04      	cmp	r3, #4
    34ce:	f040 8082 	bne.w	35d6 <main@@Base+0x13da>
    34d2:	a808      	add	r0, sp, #32
    34d4:	a914      	add	r1, sp, #80	; 0x50
    34d6:	f001 fab1 	bl	4a3c <main@@Base+0x2840>
    34da:	4605      	mov	r5, r0
    34dc:	9814      	ldr	r0, [sp, #80]	; 0x50
    34de:	2d00      	cmp	r5, #0
    34e0:	d134      	bne.n	354c <main@@Base+0x1350>
    34e2:	9b08      	ldr	r3, [sp, #32]
    34e4:	f504 768f 	add.w	r6, r4, #286	; 0x11e
    34e8:	214f      	movs	r1, #79	; 0x4f
    34ea:	46a8      	mov	r8, r5
    34ec:	4630      	mov	r0, r6
    34ee:	f8a4 311c 	strh.w	r3, [r4, #284]	; 0x11c
    34f2:	f001 fd07 	bl	4f04 <main@@Base+0x2d08>
    34f6:	234f      	movs	r3, #79	; 0x4f
    34f8:	a908      	add	r1, sp, #32
    34fa:	4632      	mov	r2, r6
    34fc:	4620      	mov	r0, r4
    34fe:	f000 fb38 	bl	3b72 <main@@Base+0x1976>
    3502:	a815      	add	r0, sp, #84	; 0x54
    3504:	4629      	mov	r1, r5
    3506:	f44f 5280 	mov.w	r2, #4096	; 0x1000
    350a:	f7fe ec66 	blx	1dd8 <memset@plt+0x4>
    350e:	2305      	movs	r3, #5
    3510:	6123      	str	r3, [r4, #16]
    3512:	e089      	b.n	3628 <main@@Base+0x142c>
    3514:	6923      	ldr	r3, [r4, #16]
    3516:	2500      	movs	r5, #0
    3518:	af14      	add	r7, sp, #80	; 0x50
    351a:	2b05      	cmp	r3, #5
    351c:	603d      	str	r5, [r7, #0]
    351e:	d15a      	bne.n	35d6 <main@@Base+0x13da>
    3520:	f7fe eb44 	blx	1bac <GetRTASGlbCtx@plt>
    3524:	f8b4 511c 	ldrh.w	r5, [r4, #284]	; 0x11c
    3528:	9911      	ldr	r1, [sp, #68]	; 0x44
    352a:	f504 738f 	add.w	r3, r4, #286	; 0x11e
    352e:	f8bd 2040 	ldrh.w	r2, [sp, #64]	; 0x40
    3532:	2d00      	cmp	r5, #0
    3534:	bf14      	ite	ne
    3536:	254f      	movne	r5, #79	; 0x4f
    3538:	2500      	moveq	r5, #0
    353a:	e88d 00a0 	stmia.w	sp, {r5, r7}
    353e:	f001 fb81 	bl	4c44 <main@@Base+0x2a48>
    3542:	b910      	cbnz	r0, 354a <main@@Base+0x134e>
    3544:	2306      	movs	r3, #6
    3546:	6123      	str	r3, [r4, #16]
    3548:	e047      	b.n	35da <main@@Base+0x13de>
    354a:	6838      	ldr	r0, [r7, #0]
    354c:	f001 fa62 	bl	4a14 <main@@Base+0x2818>
    3550:	260b      	movs	r6, #11
    3552:	4605      	mov	r5, r0
    3554:	e043      	b.n	35de <main@@Base+0x13e2>
    3556:	6923      	ldr	r3, [r4, #16]
    3558:	2b06      	cmp	r3, #6
    355a:	d13b      	bne.n	35d4 <main@@Base+0x13d8>
    355c:	f8d4 50f0 	ldr.w	r5, [r4, #240]	; 0xf0
    3560:	b935      	cbnz	r5, 3570 <main@@Base+0x1374>
    3562:	4841      	ldr	r0, [pc, #260]	; (3668 <main@@Base+0x146c>)
    3564:	4478      	add	r0, pc
    3566:	f7ff fa6b 	bl	2a40 <main@@Base+0x844>
    356a:	4606      	mov	r6, r0
    356c:	2800      	cmp	r0, #0
    356e:	d136      	bne.n	35de <main@@Base+0x13e2>
    3570:	f8bd 2040 	ldrh.w	r2, [sp, #64]	; 0x40
    3574:	4620      	mov	r0, r4
    3576:	9911      	ldr	r1, [sp, #68]	; 0x44
    3578:	f7ff fb02 	bl	2b80 <main@@Base+0x984>
    357c:	4606      	mov	r6, r0
    357e:	b908      	cbnz	r0, 3584 <main@@Base+0x1388>
    3580:	2307      	movs	r3, #7
    3582:	6123      	str	r3, [r4, #16]
    3584:	f8d4 50f0 	ldr.w	r5, [r4, #240]	; 0xf0
    3588:	bb15      	cbnz	r5, 35d0 <main@@Base+0x13d4>
    358a:	4838      	ldr	r0, [pc, #224]	; (366c <main@@Base+0x1470>)
    358c:	4478      	add	r0, pc
    358e:	f7ff fa57 	bl	2a40 <main@@Base+0x844>
    3592:	bb26      	cbnz	r6, 35de <main@@Base+0x13e2>
    3594:	4606      	mov	r6, r0
    3596:	e022      	b.n	35de <main@@Base+0x13e2>
    3598:	6923      	ldr	r3, [r4, #16]
    359a:	2b07      	cmp	r3, #7
    359c:	d11a      	bne.n	35d4 <main@@Base+0x13d8>
    359e:	4620      	mov	r0, r4
    35a0:	f7ff fcd2 	bl	2f48 <main@@Base+0xd4c>
    35a4:	4606      	mov	r6, r0
    35a6:	b998      	cbnz	r0, 35d0 <main@@Base+0x13d4>
    35a8:	2302      	movs	r3, #2
    35aa:	4605      	mov	r5, r0
    35ac:	6123      	str	r3, [r4, #16]
    35ae:	e016      	b.n	35de <main@@Base+0x13e2>
    35b0:	6923      	ldr	r3, [r4, #16]
    35b2:	2b02      	cmp	r3, #2
    35b4:	d10e      	bne.n	35d4 <main@@Base+0x13d8>
    35b6:	4620      	mov	r0, r4
    35b8:	f7ff f92d 	bl	2816 <main@@Base+0x61a>
    35bc:	4606      	mov	r6, r0
    35be:	b938      	cbnz	r0, 35d0 <main@@Base+0x13d4>
    35c0:	e00b      	b.n	35da <main@@Base+0x13de>
    35c2:	4620      	mov	r0, r4
    35c4:	f7ff fe72 	bl	32ac <main@@Base+0x10b0>
    35c8:	2500      	movs	r5, #0
    35ca:	e007      	b.n	35dc <main@@Base+0x13e0>
    35cc:	2602      	movs	r6, #2
    35ce:	e006      	b.n	35de <main@@Base+0x13e2>
    35d0:	2500      	movs	r5, #0
    35d2:	e004      	b.n	35de <main@@Base+0x13e2>
    35d4:	2500      	movs	r5, #0
    35d6:	2601      	movs	r6, #1
    35d8:	e001      	b.n	35de <main@@Base+0x13e2>
    35da:	4605      	mov	r5, r0
    35dc:	462e      	mov	r6, r5
    35de:	a815      	add	r0, sp, #84	; 0x54
    35e0:	2100      	movs	r1, #0
    35e2:	f44f 5280 	mov.w	r2, #4096	; 0x1000
    35e6:	fa1f f886 	uxth.w	r8, r6
    35ea:	f7fe ebf6 	blx	1dd8 <memset@plt+0x4>
    35ee:	f8bd 703c 	ldrh.w	r7, [sp, #60]	; 0x3c
    35f2:	b91d      	cbnz	r5, 35fc <main@@Base+0x1400>
    35f4:	4630      	mov	r0, r6
    35f6:	f000 fd9f 	bl	4138 <main@@Base+0x1f3c>
    35fa:	4605      	mov	r5, r0
    35fc:	fa0f f288 	sxth.w	r2, r8
    3600:	4620      	mov	r0, r4
    3602:	4639      	mov	r1, r7
    3604:	462b      	mov	r3, r5
    3606:	f000 fa28 	bl	3a5a <main@@Base+0x185e>
    360a:	4680      	mov	r8, r0
    360c:	4630      	mov	r0, r6
    360e:	f000 fdf3 	bl	41f8 <main@@Base+0x1ffc>
    3612:	b938      	cbnz	r0, 3624 <main@@Base+0x1428>
    3614:	f1b8 0f00 	cmp.w	r8, #0
    3618:	bfb4      	ite	lt
    361a:	f04f 38ff 	movlt.w	r8, #4294967295	; 0xffffffff
    361e:	f04f 0800 	movge.w	r8, #0
    3622:	e001      	b.n	3628 <main@@Base+0x142c>
    3624:	f04f 38ff 	mov.w	r8, #4294967295	; 0xffffffff
    3628:	f50d 518a 	add.w	r1, sp, #4416	; 0x1140
    362c:	4640      	mov	r0, r8
    362e:	312c      	adds	r1, #44	; 0x2c
    3630:	680a      	ldr	r2, [r1, #0]
    3632:	9907      	ldr	r1, [sp, #28]
    3634:	680b      	ldr	r3, [r1, #0]
    3636:	429a      	cmp	r2, r3
    3638:	d001      	beq.n	363e <main@@Base+0x1442>
    363a:	f7fe eb90 	blx	1d5c <__stack_chk_fail@plt>
    363e:	b05d      	add	sp, #372	; 0x174
    3640:	f50d 5d80 	add.w	sp, sp, #4096	; 0x1000
    3644:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
    3648:	5cdc      	ldrb	r4, [r3, r3]
    364a:	0000      	movs	r0, r0
    364c:	0258      	lsls	r0, r3, #9
    364e:	0000      	movs	r0, r0
    3650:	2a65      	cmp	r2, #101	; 0x65
    3652:	0000      	movs	r0, r0
    3654:	2a11      	cmp	r2, #17
    3656:	0000      	movs	r0, r0
    3658:	2337      	movs	r3, #55	; 0x37
    365a:	0000      	movs	r0, r0
    365c:	29e0      	cmp	r1, #224	; 0xe0
    365e:	0000      	movs	r0, r0
    3660:	2a13      	cmp	r2, #19
    3662:	0000      	movs	r0, r0
    3664:	29a8      	cmp	r1, #168	; 0xa8
    3666:	0000      	movs	r0, r0
    3668:	262c      	movs	r6, #44	; 0x2c
    366a:	0000      	movs	r0, r0
    366c:	2431      	movs	r4, #49	; 0x31
    366e:	0000      	movs	r0, r0
    3670:	4b49      	ldr	r3, [pc, #292]	; (3798 <main@@Base+0x159c>)
    3672:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
    3676:	4617      	mov	r7, r2
    3678:	4a48      	ldr	r2, [pc, #288]	; (379c <main@@Base+0x15a0>)
    367a:	447b      	add	r3, pc
    367c:	b08f      	sub	sp, #60	; 0x3c
    367e:	4605      	mov	r5, r0
    3680:	4688      	mov	r8, r1
    3682:	2400      	movs	r4, #0
    3684:	589b      	ldr	r3, [r3, r2]
    3686:	f04f 0901 	mov.w	r9, #1
    368a:	f10d 0a0c 	add.w	sl, sp, #12
    368e:	681a      	ldr	r2, [r3, #0]
    3690:	469b      	mov	fp, r3
    3692:	920d      	str	r2, [sp, #52]	; 0x34
    3694:	e06d      	b.n	3772 <main@@Base+0x1576>
    3696:	1c26      	adds	r6, r4, #0
    3698:	f8d5 30f4 	ldr.w	r3, [r5, #244]	; 0xf4
    369c:	bf18      	it	ne
    369e:	2601      	movne	r6, #1
    36a0:	2b00      	cmp	r3, #0
    36a2:	bfd4      	ite	le
    36a4:	4633      	movle	r3, r6
    36a6:	f046 0301 	orrgt.w	r3, r6, #1
    36aa:	2b00      	cmp	r3, #0
    36ac:	d049      	beq.n	3742 <main@@Base+0x1546>
    36ae:	2220      	movs	r2, #32
    36b0:	2100      	movs	r1, #0
    36b2:	a805      	add	r0, sp, #20
    36b4:	f7fe eb90 	blx	1dd8 <memset@plt+0x4>
    36b8:	68a8      	ldr	r0, [r5, #8]
    36ba:	ab0e      	add	r3, sp, #56	; 0x38
    36bc:	f100 021f 	add.w	r2, r0, #31
    36c0:	ea12 0220 	ands.w	r2, r2, r0, asr #32
    36c4:	bf38      	it	cc
    36c6:	4602      	movcc	r2, r0
    36c8:	1152      	asrs	r2, r2, #5
    36ca:	eb03 0282 	add.w	r2, r3, r2, lsl #2
    36ce:	4b31      	ldr	r3, [pc, #196]	; (3794 <main@@Base+0x1598>)
    36d0:	4003      	ands	r3, r0
    36d2:	2b00      	cmp	r3, #0
    36d4:	da03      	bge.n	36de <main@@Base+0x14e2>
    36d6:	3b01      	subs	r3, #1
    36d8:	f063 031f 	orn	r3, r3, #31
    36dc:	3301      	adds	r3, #1
    36de:	fa09 f303 	lsl.w	r3, r9, r3
    36e2:	f842 3c24 	str.w	r3, [r2, #-36]
    36e6:	2200      	movs	r2, #0
    36e8:	2e00      	cmp	r6, #0
    36ea:	bf0c      	ite	eq
    36ec:	2378      	moveq	r3, #120	; 0x78
    36ee:	2303      	movne	r3, #3
    36f0:	3001      	adds	r0, #1
    36f2:	9303      	str	r3, [sp, #12]
    36f4:	a905      	add	r1, sp, #20
    36f6:	4613      	mov	r3, r2
    36f8:	9204      	str	r2, [sp, #16]
    36fa:	f8cd a000 	str.w	sl, [sp]
    36fe:	f7fe ed1e 	blx	213c <select@plt>
    3702:	2800      	cmp	r0, #0
    3704:	da09      	bge.n	371a <main@@Base+0x151e>
    3706:	f7fe ea84 	blx	1c10 <__get_errno_ptr@plt>
    370a:	6800      	ldr	r0, [r0, #0]
    370c:	f7fe ea86 	blx	1c1c <strerror@plt>
    3710:	4923      	ldr	r1, [pc, #140]	; (37a0 <main@@Base+0x15a4>)
    3712:	4479      	add	r1, pc
    3714:	4602      	mov	r2, r0
    3716:	2002      	movs	r0, #2
    3718:	e024      	b.n	3764 <main@@Base+0x1568>
    371a:	bf14      	ite	ne
    371c:	2300      	movne	r3, #0
    371e:	2301      	moveq	r3, #1
    3720:	4233      	tst	r3, r6
    3722:	d005      	beq.n	3730 <main@@Base+0x1534>
    3724:	491f      	ldr	r1, [pc, #124]	; (37a4 <main@@Base+0x15a8>)
    3726:	2002      	movs	r0, #2
    3728:	4479      	add	r1, pc
    372a:	f000 fd0d 	bl	4148 <main@@Base+0x1f4c>
    372e:	e01b      	b.n	3768 <main@@Base+0x156c>
    3730:	b13b      	cbz	r3, 3742 <main@@Base+0x1546>
    3732:	491d      	ldr	r1, [pc, #116]	; (37a8 <main@@Base+0x15ac>)
    3734:	2002      	movs	r0, #2
    3736:	4479      	add	r1, pc
    3738:	f000 fd06 	bl	4148 <main@@Base+0x1f4c>
    373c:	f06f 0008 	mvn.w	r0, #8
    3740:	e01d      	b.n	377e <main@@Base+0x1582>
    3742:	2300      	movs	r3, #0
    3744:	1b3a      	subs	r2, r7, r4
    3746:	68a8      	ldr	r0, [r5, #8]
    3748:	4641      	mov	r1, r8
    374a:	f7fe ec12 	blx	1f70 <recv@plt>
    374e:	2800      	cmp	r0, #0
    3750:	da0d      	bge.n	376e <main@@Base+0x1572>
    3752:	f7fe ea5e 	blx	1c10 <__get_errno_ptr@plt>
    3756:	6800      	ldr	r0, [r0, #0]
    3758:	f7fe ea60 	blx	1c1c <strerror@plt>
    375c:	4913      	ldr	r1, [pc, #76]	; (37ac <main@@Base+0x15b0>)
    375e:	4479      	add	r1, pc
    3760:	4602      	mov	r2, r0
    3762:	2002      	movs	r0, #2
    3764:	f000 fcf0 	bl	4148 <main@@Base+0x1f4c>
    3768:	f04f 30ff 	mov.w	r0, #4294967295	; 0xffffffff
    376c:	e007      	b.n	377e <main@@Base+0x1582>
    376e:	d004      	beq.n	377a <main@@Base+0x157e>
    3770:	1824      	adds	r4, r4, r0
    3772:	42bc      	cmp	r4, r7
    3774:	d38f      	bcc.n	3696 <main@@Base+0x149a>
    3776:	4620      	mov	r0, r4
    3778:	e001      	b.n	377e <main@@Base+0x1582>
    377a:	f06f 0007 	mvn.w	r0, #7
    377e:	9a0d      	ldr	r2, [sp, #52]	; 0x34
    3780:	f8db 3000 	ldr.w	r3, [fp]
    3784:	429a      	cmp	r2, r3
    3786:	d001      	beq.n	378c <main@@Base+0x1590>
    3788:	f7fe eae8 	blx	1d5c <__stack_chk_fail@plt>
    378c:	b00f      	add	sp, #60	; 0x3c
    378e:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
    3792:	bf00      	nop
    3794:	001f      	movs	r7, r3
    3796:	8000      	strh	r0, [r0, #0]
    3798:	5982      	ldr	r2, [r0, r6]
    379a:	0000      	movs	r0, r0
    379c:	0258      	lsls	r0, r3, #9
    379e:	0000      	movs	r0, r0
    37a0:	281f      	cmp	r0, #31
    37a2:	0000      	movs	r0, r0
    37a4:	2826      	cmp	r0, #38	; 0x26
    37a6:	0000      	movs	r0, r0
    37a8:	2842      	cmp	r0, #66	; 0x42
    37aa:	0000      	movs	r0, r0
    37ac:	283e      	cmp	r0, #62	; 0x3e
    37ae:	0000      	movs	r0, r0
    37b0:	4b30      	ldr	r3, [pc, #192]	; (3874 <main@@Base+0x1678>)
    37b2:	2101      	movs	r1, #1
    37b4:	4a30      	ldr	r2, [pc, #192]	; (3878 <main@@Base+0x167c>)
    37b6:	447b      	add	r3, pc
    37b8:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
    37bc:	b088      	sub	sp, #32
    37be:	589e      	ldr	r6, [r3, r2]
    37c0:	4607      	mov	r7, r0
    37c2:	2200      	movs	r2, #0
    37c4:	2002      	movs	r0, #2
    37c6:	6833      	ldr	r3, [r6, #0]
    37c8:	9307      	str	r3, [sp, #28]
    37ca:	f7fe e9d8 	blx	1b7c <socket@plt>
    37ce:	2800      	cmp	r0, #0
    37d0:	4604      	mov	r4, r0
    37d2:	db38      	blt.n	3846 <main@@Base+0x164a>
    37d4:	ab08      	add	r3, sp, #32
    37d6:	2204      	movs	r2, #4
    37d8:	f64f 71ff 	movw	r1, #65535	; 0xffff
    37dc:	b2bf      	uxth	r7, r7
    37de:	2501      	movs	r5, #1
    37e0:	f843 5d18 	str.w	r5, [r3, #-24]!
    37e4:	9200      	str	r2, [sp, #0]
    37e6:	f7fe ebd6 	blx	1f94 <setsockopt@plt>
    37ea:	2100      	movs	r1, #0
    37ec:	2210      	movs	r2, #16
    37ee:	a803      	add	r0, sp, #12
    37f0:	f04f 0802 	mov.w	r8, #2
    37f4:	f7fe eaf0 	blx	1dd8 <memset@plt+0x4>
    37f8:	063b      	lsls	r3, r7, #24
    37fa:	4620      	mov	r0, r4
    37fc:	0a3f      	lsrs	r7, r7, #8
    37fe:	a903      	add	r1, sp, #12
    3800:	2210      	movs	r2, #16
    3802:	ea47 4713 	orr.w	r7, r7, r3, lsr #16
    3806:	f88d 800d 	strb.w	r8, [sp, #13]
    380a:	f8ad 700e 	strh.w	r7, [sp, #14]
    380e:	f7fe eb08 	blx	1e20 <bind@plt>
    3812:	b970      	cbnz	r0, 3832 <main@@Base+0x1636>
    3814:	4620      	mov	r0, r4
    3816:	4629      	mov	r1, r5
    3818:	f7fe ea8e 	blx	1d38 <listen@plt>
    381c:	b300      	cbz	r0, 3860 <main@@Base+0x1664>
    381e:	f7fe e9f8 	blx	1c10 <__get_errno_ptr@plt>
    3822:	6800      	ldr	r0, [r0, #0]
    3824:	f7fe e9fa 	blx	1c1c <strerror@plt>
    3828:	4914      	ldr	r1, [pc, #80]	; (387c <main@@Base+0x1680>)
    382a:	4479      	add	r1, pc
    382c:	4602      	mov	r2, r0
    382e:	4640      	mov	r0, r8
    3830:	e012      	b.n	3858 <main@@Base+0x165c>
    3832:	f7fe e9ee 	blx	1c10 <__get_errno_ptr@plt>
    3836:	6800      	ldr	r0, [r0, #0]
    3838:	f7fe e9f0 	blx	1c1c <strerror@plt>
    383c:	4910      	ldr	r1, [pc, #64]	; (3880 <main@@Base+0x1684>)
    383e:	4479      	add	r1, pc
    3840:	4602      	mov	r2, r0
    3842:	4640      	mov	r0, r8
    3844:	e008      	b.n	3858 <main@@Base+0x165c>
    3846:	f7fe e9e4 	blx	1c10 <__get_errno_ptr@plt>
    384a:	6800      	ldr	r0, [r0, #0]
    384c:	f7fe e9e6 	blx	1c1c <strerror@plt>
    3850:	490c      	ldr	r1, [pc, #48]	; (3884 <main@@Base+0x1688>)
    3852:	4479      	add	r1, pc
    3854:	4602      	mov	r2, r0
    3856:	2002      	movs	r0, #2
    3858:	f000 fc76 	bl	4148 <main@@Base+0x1f4c>
    385c:	f04f 34ff 	mov.w	r4, #4294967295	; 0xffffffff
    3860:	9a07      	ldr	r2, [sp, #28]
    3862:	4620      	mov	r0, r4
    3864:	6833      	ldr	r3, [r6, #0]
    3866:	429a      	cmp	r2, r3
    3868:	d001      	beq.n	386e <main@@Base+0x1672>
    386a:	f7fe ea78 	blx	1d5c <__stack_chk_fail@plt>
    386e:	b008      	add	sp, #32
    3870:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
    3874:	5846      	ldr	r6, [r0, r1]
    3876:	0000      	movs	r0, r0
    3878:	0258      	lsls	r0, r3, #9
    387a:	0000      	movs	r0, r0
    387c:	278d      	movs	r7, #141	; 0x8d
    387e:	0000      	movs	r0, r0
    3880:	279a      	movs	r7, #154	; 0x9a
    3882:	0000      	movs	r0, r0
    3884:	27a5      	movs	r7, #165	; 0xa5
    3886:	0000      	movs	r0, r0
    3888:	6800      	ldr	r0, [r0, #0]
    388a:	f7fe b995 	b.w	1bb8 <close@plt>
    388e:	1dc3      	adds	r3, r0, #7
    3890:	2b07      	cmp	r3, #7
    3892:	d81a      	bhi.n	38ca <main@@Base+0x16ce>
    3894:	e8df f003 	tbb	[pc, r3]
    3898:	1013      	asrs	r3, r2, #32
    389a:	0a0d      	lsrs	r5, r1, #8
    389c:	1e07      	subs	r7, r0, #0
    389e:	1604      	asrs	r4, r0, #24
    38a0:	480f      	ldr	r0, [pc, #60]	; (38e0 <main@@Base+0x16e4>)
    38a2:	4478      	add	r0, pc
    38a4:	4770      	bx	lr
    38a6:	480f      	ldr	r0, [pc, #60]	; (38e4 <main@@Base+0x16e8>)
    38a8:	4478      	add	r0, pc
    38aa:	4770      	bx	lr
    38ac:	480e      	ldr	r0, [pc, #56]	; (38e8 <main@@Base+0x16ec>)
    38ae:	4478      	add	r0, pc
    38b0:	4770      	bx	lr
    38b2:	480e      	ldr	r0, [pc, #56]	; (38ec <main@@Base+0x16f0>)
    38b4:	4478      	add	r0, pc
    38b6:	4770      	bx	lr
    38b8:	480d      	ldr	r0, [pc, #52]	; (38f0 <main@@Base+0x16f4>)
    38ba:	4478      	add	r0, pc
    38bc:	4770      	bx	lr
    38be:	480d      	ldr	r0, [pc, #52]	; (38f4 <main@@Base+0x16f8>)
    38c0:	4478      	add	r0, pc
    38c2:	4770      	bx	lr
    38c4:	480c      	ldr	r0, [pc, #48]	; (38f8 <main@@Base+0x16fc>)
    38c6:	4478      	add	r0, pc
    38c8:	4770      	bx	lr
    38ca:	2800      	cmp	r0, #0
    38cc:	dd05      	ble.n	38da <main@@Base+0x16de>
    38ce:	480b      	ldr	r0, [pc, #44]	; (38fc <main@@Base+0x1700>)
    38d0:	4478      	add	r0, pc
    38d2:	4770      	bx	lr
    38d4:	480a      	ldr	r0, [pc, #40]	; (3900 <main@@Base+0x1704>)
    38d6:	4478      	add	r0, pc
    38d8:	4770      	bx	lr
    38da:	480a      	ldr	r0, [pc, #40]	; (3904 <main@@Base+0x1708>)
    38dc:	4478      	add	r0, pc
    38de:	4770      	bx	lr
    38e0:	2776      	movs	r7, #118	; 0x76
    38e2:	0000      	movs	r0, r0
    38e4:	279e      	movs	r7, #158	; 0x9e
    38e6:	0000      	movs	r0, r0
    38e8:	27a8      	movs	r7, #168	; 0xa8
    38ea:	0000      	movs	r0, r0
    38ec:	27bb      	movs	r7, #187	; 0xbb
    38ee:	0000      	movs	r0, r0
    38f0:	27c8      	movs	r7, #200	; 0xc8
    38f2:	0000      	movs	r0, r0
    38f4:	27de      	movs	r7, #222	; 0xde
    38f6:	0000      	movs	r0, r0
    38f8:	27f1      	movs	r7, #241	; 0xf1
    38fa:	0000      	movs	r0, r0
    38fc:	27e7      	movs	r7, #231	; 0xe7
    38fe:	0000      	movs	r0, r0
    3900:	2750      	movs	r7, #80	; 0x50
    3902:	0000      	movs	r0, r0
    3904:	27e4      	movs	r7, #228	; 0xe4
    3906:	0000      	movs	r0, r0
    3908:	3306      	adds	r3, #6
    390a:	b292      	uxth	r2, r2
    390c:	b29b      	uxth	r3, r3
    390e:	0619      	lsls	r1, r3, #24
    3910:	0a1b      	lsrs	r3, r3, #8
    3912:	ea43 4311 	orr.w	r3, r3, r1, lsr #16
    3916:	8003      	strh	r3, [r0, #0]
    3918:	f44f 7300 	mov.w	r3, #512	; 0x200
    391c:	8043      	strh	r3, [r0, #2]
    391e:	0613      	lsls	r3, r2, #24
    3920:	0a12      	lsrs	r2, r2, #8
    3922:	ea42 4213 	orr.w	r2, r2, r3, lsr #16
    3926:	8082      	strh	r2, [r0, #4]
    3928:	2006      	movs	r0, #6
    392a:	4770      	bx	lr
    392c:	4b28      	ldr	r3, [pc, #160]	; (39d0 <main@@Base+0x17d4>)
    392e:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
    3932:	4614      	mov	r4, r2
    3934:	4a27      	ldr	r2, [pc, #156]	; (39d4 <main@@Base+0x17d8>)
    3936:	447b      	add	r3, pc
    3938:	f5ad 5d80 	sub.w	sp, sp, #4096	; 0x1000
    393c:	4607      	mov	r7, r0
    393e:	b082      	sub	sp, #8
    3940:	460e      	mov	r6, r1
    3942:	589d      	ldr	r5, [r3, r2]
    3944:	f50d 5280 	add.w	r2, sp, #4096	; 0x1000
    3948:	3204      	adds	r2, #4
    394a:	a801      	add	r0, sp, #4
    394c:	f44f 5180 	mov.w	r1, #4096	; 0x1000
    3950:	682b      	ldr	r3, [r5, #0]
    3952:	6013      	str	r3, [r2, #0]
    3954:	2204      	movs	r2, #4
    3956:	b2a3      	uxth	r3, r4
    3958:	f7ff ffd6 	bl	3908 <main@@Base+0x170c>
    395c:	2800      	cmp	r0, #0
    395e:	db28      	blt.n	39b2 <main@@Base+0x17b6>
    3960:	f8d7 8008 	ldr.w	r8, [r7, #8]
    3964:	1907      	adds	r7, r0, r4
    3966:	f5b7 5f80 	cmp.w	r7, #4096	; 0x1000
    396a:	d907      	bls.n	397c <main@@Base+0x1780>
    396c:	491a      	ldr	r1, [pc, #104]	; (39d8 <main@@Base+0x17dc>)
    396e:	2002      	movs	r0, #2
    3970:	4479      	add	r1, pc
    3972:	f000 fbe9 	bl	4148 <main@@Base+0x1f4c>
    3976:	f06f 0006 	mvn.w	r0, #6
    397a:	e01a      	b.n	39b2 <main@@Base+0x17b6>
    397c:	ab01      	add	r3, sp, #4
    397e:	4631      	mov	r1, r6
    3980:	1818      	adds	r0, r3, r0
    3982:	4622      	mov	r2, r4
    3984:	f7fe e9c0 	blx	1d08 <memcpy@plt+0x4>
    3988:	2300      	movs	r3, #0
    398a:	4640      	mov	r0, r8
    398c:	a901      	add	r1, sp, #4
    398e:	463a      	mov	r2, r7
    3990:	f7fe e97c 	blx	1c8c <send@plt>
    3994:	2800      	cmp	r0, #0
    3996:	da0c      	bge.n	39b2 <main@@Base+0x17b6>
    3998:	f7fe e93a 	blx	1c10 <__get_errno_ptr@plt>
    399c:	6800      	ldr	r0, [r0, #0]
    399e:	f7fe e93e 	blx	1c1c <strerror@plt>
    39a2:	490e      	ldr	r1, [pc, #56]	; (39dc <main@@Base+0x17e0>)
    39a4:	4479      	add	r1, pc
    39a6:	4602      	mov	r2, r0
    39a8:	2002      	movs	r0, #2
    39aa:	f000 fbcd 	bl	4148 <main@@Base+0x1f4c>
    39ae:	f04f 30ff 	mov.w	r0, #4294967295	; 0xffffffff
    39b2:	f50d 5380 	add.w	r3, sp, #4096	; 0x1000
    39b6:	3304      	adds	r3, #4
    39b8:	681a      	ldr	r2, [r3, #0]
    39ba:	682b      	ldr	r3, [r5, #0]
    39bc:	429a      	cmp	r2, r3
    39be:	d001      	beq.n	39c4 <main@@Base+0x17c8>
    39c0:	f7fe e9cc 	blx	1d5c <__stack_chk_fail@plt>
    39c4:	b002      	add	sp, #8
    39c6:	f50d 5d80 	add.w	sp, sp, #4096	; 0x1000
    39ca:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
    39ce:	bf00      	nop
    39d0:	56c6      	ldrsb	r6, [r0, r3]
    39d2:	0000      	movs	r0, r0
    39d4:	0258      	lsls	r0, r3, #9
    39d6:	0000      	movs	r0, r0
    39d8:	275e      	movs	r7, #94	; 0x5e
    39da:	0000      	movs	r0, r0
    39dc:	2753      	movs	r7, #83	; 0x53
    39de:	0000      	movs	r0, r0
    39e0:	e92d 43f8 	stmdb	sp!, {r3, r4, r5, r6, r7, r8, r9, lr}
    39e4:	4605      	mov	r5, r0
    39e6:	9e08      	ldr	r6, [sp, #32]
    39e8:	4689      	mov	r9, r1
    39ea:	4698      	mov	r8, r3
    39ec:	4634      	mov	r4, r6
    39ee:	b11e      	cbz	r6, 39f8 <main@@Base+0x17fc>
    39f0:	4630      	mov	r0, r6
    39f2:	f7fe ebaa 	blx	2148 <strlen@plt>
    39f6:	1c44      	adds	r4, r0, #1
    39f8:	f104 0318 	add.w	r3, r4, #24
    39fc:	4599      	cmp	r9, r3
    39fe:	d324      	bcc.n	3a4a <main@@Base+0x184e>
    3a00:	b2a7      	uxth	r7, r4
    3a02:	2202      	movs	r2, #2
    3a04:	1d3b      	adds	r3, r7, #4
    3a06:	4628      	mov	r0, r5
    3a08:	4649      	mov	r1, r9
    3a0a:	b29b      	uxth	r3, r3
    3a0c:	f7ff ff7c 	bl	3908 <main@@Base+0x170c>
    3a10:	2800      	cmp	r0, #0
    3a12:	db1e      	blt.n	3a52 <main@@Base+0x1856>
    3a14:	fa1f f888 	uxth.w	r8, r8
    3a18:	182b      	adds	r3, r5, r0
    3a1a:	ea4f 6208 	mov.w	r2, r8, lsl #24
    3a1e:	ea4f 2818 	mov.w	r8, r8, lsr #8
    3a22:	ea48 4812 	orr.w	r8, r8, r2, lsr #16
    3a26:	063a      	lsls	r2, r7, #24
    3a28:	0a3f      	lsrs	r7, r7, #8
    3a2a:	f825 8000 	strh.w	r8, [r5, r0]
    3a2e:	ea47 4712 	orr.w	r7, r7, r2, lsr #16
    3a32:	805f      	strh	r7, [r3, #2]
    3a34:	1d1f      	adds	r7, r3, #4
    3a36:	b12c      	cbz	r4, 3a44 <main@@Base+0x1848>
    3a38:	4638      	mov	r0, r7
    3a3a:	4631      	mov	r1, r6
    3a3c:	4622      	mov	r2, r4
    3a3e:	193f      	adds	r7, r7, r4
    3a40:	f7fe e962 	blx	1d08 <memcpy@plt+0x4>
    3a44:	1b78      	subs	r0, r7, r5
    3a46:	e8bd 83f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, pc}
    3a4a:	f04f 30ff 	mov.w	r0, #4294967295	; 0xffffffff
    3a4e:	e8bd 83f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, pc}
    3a52:	f04f 30ff 	mov.w	r0, #4294967295	; 0xffffffff
    3a56:	e8bd 83f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, pc}
    3a5a:	b5f0      	push	{r4, r5, r6, r7, lr}
    3a5c:	4616      	mov	r6, r2
    3a5e:	4a1e      	ldr	r2, [pc, #120]	; (3ad8 <main@@Base+0x18dc>)
    3a60:	460f      	mov	r7, r1
    3a62:	491e      	ldr	r1, [pc, #120]	; (3adc <main@@Base+0x18e0>)
    3a64:	f5ad 5d80 	sub.w	sp, sp, #4096	; 0x1000
    3a68:	447a      	add	r2, pc
    3a6a:	b085      	sub	sp, #20
    3a6c:	4605      	mov	r5, r0
    3a6e:	a803      	add	r0, sp, #12
    3a70:	5854      	ldr	r4, [r2, r1]
    3a72:	f50d 5180 	add.w	r1, sp, #4096	; 0x1000
    3a76:	310c      	adds	r1, #12
    3a78:	6822      	ldr	r2, [r4, #0]
    3a7a:	600a      	str	r2, [r1, #0]
    3a7c:	463a      	mov	r2, r7
    3a7e:	9300      	str	r3, [sp, #0]
    3a80:	f44f 5180 	mov.w	r1, #4096	; 0x1000
    3a84:	4633      	mov	r3, r6
    3a86:	f7ff ffab 	bl	39e0 <main@@Base+0x17e4>
    3a8a:	2800      	cmp	r0, #0
    3a8c:	4602      	mov	r2, r0
    3a8e:	dd14      	ble.n	3aba <main@@Base+0x18be>
    3a90:	2300      	movs	r3, #0
    3a92:	68a8      	ldr	r0, [r5, #8]
    3a94:	a903      	add	r1, sp, #12
    3a96:	f7fe e8fa 	blx	1c8c <send@plt>
    3a9a:	2800      	cmp	r0, #0
    3a9c:	4602      	mov	r2, r0
    3a9e:	da0c      	bge.n	3aba <main@@Base+0x18be>
    3aa0:	f7fe e8b6 	blx	1c10 <__get_errno_ptr@plt>
    3aa4:	6800      	ldr	r0, [r0, #0]
    3aa6:	f7fe e8ba 	blx	1c1c <strerror@plt>
    3aaa:	490d      	ldr	r1, [pc, #52]	; (3ae0 <main@@Base+0x18e4>)
    3aac:	4479      	add	r1, pc
    3aae:	4602      	mov	r2, r0
    3ab0:	2002      	movs	r0, #2
    3ab2:	f000 fb49 	bl	4148 <main@@Base+0x1f4c>
    3ab6:	f04f 32ff 	mov.w	r2, #4294967295	; 0xffffffff
    3aba:	f50d 5380 	add.w	r3, sp, #4096	; 0x1000
    3abe:	4610      	mov	r0, r2
    3ac0:	330c      	adds	r3, #12
    3ac2:	681a      	ldr	r2, [r3, #0]
    3ac4:	6823      	ldr	r3, [r4, #0]
    3ac6:	429a      	cmp	r2, r3
    3ac8:	d001      	beq.n	3ace <main@@Base+0x18d2>
    3aca:	f7fe e948 	blx	1d5c <__stack_chk_fail@plt>
    3ace:	b005      	add	sp, #20
    3ad0:	f50d 5d80 	add.w	sp, sp, #4096	; 0x1000
    3ad4:	bdf0      	pop	{r4, r5, r6, r7, pc}
    3ad6:	bf00      	nop
    3ad8:	5594      	strb	r4, [r2, r6]
    3ada:	0000      	movs	r0, r0
    3adc:	0258      	lsls	r0, r3, #9
    3ade:	0000      	movs	r0, r0
    3ae0:	266d      	movs	r6, #109	; 0x6d
    3ae2:	0000      	movs	r0, r0
    3ae4:	e92d 43f8 	stmdb	sp!, {r3, r4, r5, r6, r7, r8, r9, lr}
    3ae8:	4606      	mov	r6, r0
    3aea:	6814      	ldr	r4, [r2, #0]
    3aec:	4617      	mov	r7, r2
    3aee:	4698      	mov	r8, r3
    3af0:	9d08      	ldr	r5, [sp, #32]
    3af2:	2c00      	cmp	r4, #0
    3af4:	d139      	bne.n	3b6a <main@@Base+0x196e>
    3af6:	2314      	movs	r3, #20
    3af8:	4625      	mov	r5, r4
    3afa:	1d9a      	adds	r2, r3, #6
    3afc:	4291      	cmp	r1, r2
    3afe:	d32c      	bcc.n	3b5a <main@@Base+0x195e>
    3b00:	2209      	movs	r2, #9
    3b02:	b29b      	uxth	r3, r3
    3b04:	4630      	mov	r0, r6
    3b06:	f7ff feff 	bl	3908 <main@@Base+0x170c>
    3b0a:	2800      	cmp	r0, #0
    3b0c:	db29      	blt.n	3b62 <main@@Base+0x1966>
    3b0e:	683b      	ldr	r3, [r7, #0]
    3b10:	eb06 0900 	add.w	r9, r6, r0
    3b14:	f107 0110 	add.w	r1, r7, #16
    3b18:	ba1b      	rev	r3, r3
    3b1a:	5033      	str	r3, [r6, r0]
    3b1c:	68bb      	ldr	r3, [r7, #8]
    3b1e:	ba1b      	rev	r3, r3
    3b20:	f8c9 3004 	str.w	r3, [r9, #4]
    3b24:	0623      	lsls	r3, r4, #24
    3b26:	0c1b      	lsrs	r3, r3, #16
    3b28:	f8a9 3008 	strh.w	r3, [r9, #8]
    3b2c:	b2ab      	uxth	r3, r5
    3b2e:	061a      	lsls	r2, r3, #24
    3b30:	0a1b      	lsrs	r3, r3, #8
    3b32:	ea43 4312 	orr.w	r3, r3, r2, lsr #16
    3b36:	f8a9 300a 	strh.w	r3, [r9, #10]
    3b3a:	f109 090c 	add.w	r9, r9, #12
    3b3e:	4622      	mov	r2, r4
    3b40:	444c      	add	r4, r9
    3b42:	4648      	mov	r0, r9
    3b44:	f7fe e8e0 	blx	1d08 <memcpy@plt+0x4>
    3b48:	4620      	mov	r0, r4
    3b4a:	4641      	mov	r1, r8
    3b4c:	462a      	mov	r2, r5
    3b4e:	1964      	adds	r4, r4, r5
    3b50:	f7fe e8da 	blx	1d08 <memcpy@plt+0x4>
    3b54:	1ba0      	subs	r0, r4, r6
    3b56:	e8bd 83f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, pc}
    3b5a:	f04f 30ff 	mov.w	r0, #4294967295	; 0xffffffff
    3b5e:	e8bd 83f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, pc}
    3b62:	f04f 30ff 	mov.w	r0, #4294967295	; 0xffffffff
    3b66:	e8bd 83f8 	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, pc}
    3b6a:	f105 031c 	add.w	r3, r5, #28
    3b6e:	2408      	movs	r4, #8
    3b70:	e7c3      	b.n	3afa <main@@Base+0x18fe>
    3b72:	b5f0      	push	{r4, r5, r6, r7, lr}
    3b74:	4616      	mov	r6, r2
    3b76:	4a1e      	ldr	r2, [pc, #120]	; (3bf0 <main@@Base+0x19f4>)
    3b78:	460f      	mov	r7, r1
    3b7a:	491e      	ldr	r1, [pc, #120]	; (3bf4 <main@@Base+0x19f8>)
    3b7c:	f5ad 5d80 	sub.w	sp, sp, #4096	; 0x1000
    3b80:	447a      	add	r2, pc
    3b82:	b085      	sub	sp, #20
    3b84:	4605      	mov	r5, r0
    3b86:	a803      	add	r0, sp, #12
    3b88:	5854      	ldr	r4, [r2, r1]
    3b8a:	f50d 5180 	add.w	r1, sp, #4096	; 0x1000
    3b8e:	310c      	adds	r1, #12
    3b90:	6822      	ldr	r2, [r4, #0]
    3b92:	600a      	str	r2, [r1, #0]
    3b94:	463a      	mov	r2, r7
    3b96:	9300      	str	r3, [sp, #0]
    3b98:	f44f 5180 	mov.w	r1, #4096	; 0x1000
    3b9c:	4633      	mov	r3, r6
    3b9e:	f7ff ffa1 	bl	3ae4 <main@@Base+0x18e8>
    3ba2:	2800      	cmp	r0, #0
    3ba4:	4602      	mov	r2, r0
    3ba6:	dd14      	ble.n	3bd2 <main@@Base+0x19d6>
    3ba8:	2300      	movs	r3, #0
    3baa:	68a8      	ldr	r0, [r5, #8]
    3bac:	a903      	add	r1, sp, #12
    3bae:	f7fe e86e 	blx	1c8c <send@plt>
    3bb2:	2800      	cmp	r0, #0
    3bb4:	4602      	mov	r2, r0
    3bb6:	da0c      	bge.n	3bd2 <main@@Base+0x19d6>
    3bb8:	f7fe e82a 	blx	1c10 <__get_errno_ptr@plt>
    3bbc:	6800      	ldr	r0, [r0, #0]
    3bbe:	f7fe e82e 	blx	1c1c <strerror@plt>
    3bc2:	490d      	ldr	r1, [pc, #52]	; (3bf8 <main@@Base+0x19fc>)
    3bc4:	4479      	add	r1, pc
    3bc6:	4602      	mov	r2, r0
    3bc8:	2002      	movs	r0, #2
    3bca:	f000 fabd 	bl	4148 <main@@Base+0x1f4c>
    3bce:	f04f 32ff 	mov.w	r2, #4294967295	; 0xffffffff
    3bd2:	f50d 5380 	add.w	r3, sp, #4096	; 0x1000
    3bd6:	4610      	mov	r0, r2
    3bd8:	330c      	adds	r3, #12
    3bda:	681a      	ldr	r2, [r3, #0]
    3bdc:	6823      	ldr	r3, [r4, #0]
    3bde:	429a      	cmp	r2, r3
    3be0:	d001      	beq.n	3be6 <main@@Base+0x19ea>
    3be2:	f7fe e8bc 	blx	1d5c <__stack_chk_fail@plt>
    3be6:	b005      	add	sp, #20
    3be8:	f50d 5d80 	add.w	sp, sp, #4096	; 0x1000
    3bec:	bdf0      	pop	{r4, r5, r6, r7, pc}
    3bee:	bf00      	nop
    3bf0:	547c      	strb	r4, [r7, r1]
    3bf2:	0000      	movs	r0, r0
    3bf4:	0258      	lsls	r0, r3, #9
    3bf6:	0000      	movs	r0, r0
    3bf8:	256f      	movs	r5, #111	; 0x6f
    3bfa:	0000      	movs	r0, r0
    3bfc:	8803      	ldrh	r3, [r0, #0]
    3bfe:	061a      	lsls	r2, r3, #24
    3c00:	0a1b      	lsrs	r3, r3, #8
    3c02:	ea43 4312 	orr.w	r3, r3, r2, lsr #16
    3c06:	800b      	strh	r3, [r1, #0]
    3c08:	8842      	ldrh	r2, [r0, #2]
    3c0a:	0613      	lsls	r3, r2, #24
    3c0c:	0a12      	lsrs	r2, r2, #8
    3c0e:	ea42 4313 	orr.w	r3, r2, r3, lsr #16
    3c12:	804b      	strh	r3, [r1, #2]
    3c14:	8882      	ldrh	r2, [r0, #4]
    3c16:	0610      	lsls	r0, r2, #24
    3c18:	0a12      	lsrs	r2, r2, #8
    3c1a:	2b02      	cmp	r3, #2
    3c1c:	ea42 4210 	orr.w	r2, r2, r0, lsr #16
    3c20:	bf14      	ite	ne
    3c22:	f06f 0001 	mvnne.w	r0, #1
    3c26:	2006      	moveq	r0, #6
    3c28:	808a      	strh	r2, [r1, #4]
    3c2a:	4770      	bx	lr
    3c2c:	8803      	ldrh	r3, [r0, #0]
    3c2e:	b570      	push	{r4, r5, r6, lr}
    3c30:	1d06      	adds	r6, r0, #4
    3c32:	061a      	lsls	r2, r3, #24
    3c34:	0a1b      	lsrs	r3, r3, #8
    3c36:	460d      	mov	r5, r1
    3c38:	4604      	mov	r4, r0
    3c3a:	ea43 4312 	orr.w	r3, r3, r2, lsr #16
    3c3e:	800b      	strh	r3, [r1, #0]
    3c40:	8843      	ldrh	r3, [r0, #2]
    3c42:	1d08      	adds	r0, r1, #4
    3c44:	061a      	lsls	r2, r3, #24
    3c46:	0a1b      	lsrs	r3, r3, #8
    3c48:	ea43 4312 	orr.w	r3, r3, r2, lsr #16
    3c4c:	2210      	movs	r2, #16
    3c4e:	804b      	strh	r3, [r1, #2]
    3c50:	4631      	mov	r1, r6
    3c52:	f7fe e85a 	blx	1d08 <memcpy@plt+0x4>
    3c56:	8828      	ldrh	r0, [r5, #0]
    3c58:	f104 0314 	add.w	r3, r4, #20
    3c5c:	616b      	str	r3, [r5, #20]
    3c5e:	eb06 0640 	add.w	r6, r6, r0, lsl #1
    3c62:	1b34      	subs	r4, r6, r4
    3c64:	1060      	asrs	r0, r4, #1
    3c66:	bd70      	pop	{r4, r5, r6, pc}
    3c68:	e92d 43f0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, lr}
    3c6c:	4616      	mov	r6, r2
    3c6e:	4a3d      	ldr	r2, [pc, #244]	; (3d64 <main@@Base+0x1b68>)
    3c70:	4688      	mov	r8, r1
    3c72:	493d      	ldr	r1, [pc, #244]	; (3d68 <main@@Base+0x1b6c>)
    3c74:	f5ad 5d80 	sub.w	sp, sp, #4096	; 0x1000
    3c78:	447a      	add	r2, pc
    3c7a:	b08b      	sub	sp, #44	; 0x2c
    3c7c:	4604      	mov	r4, r0
    3c7e:	f50d 5082 	add.w	r0, sp, #4160	; 0x1040
    3c82:	5852      	ldr	r2, [r2, r1]
    3c84:	3008      	adds	r0, #8
    3c86:	ad02      	add	r5, sp, #8
    3c88:	6807      	ldr	r7, [r0, #0]
    3c8a:	f50d 5080 	add.w	r0, sp, #4096	; 0x1000
    3c8e:	6811      	ldr	r1, [r2, #0]
    3c90:	3024      	adds	r0, #36	; 0x24
    3c92:	4691      	mov	r9, r2
    3c94:	6001      	str	r1, [r0, #0]
    3c96:	2100      	movs	r1, #0
    3c98:	2b17      	cmp	r3, #23
    3c9a:	6029      	str	r1, [r5, #0]
    3c9c:	bf98      	it	ls
    3c9e:	f06f 000b 	mvnls.w	r0, #11
    3ca2:	d945      	bls.n	3d30 <main@@Base+0x1b34>
    3ca4:	f640 72fa 	movw	r2, #4090	; 0xffa
    3ca8:	4293      	cmp	r3, r2
    3caa:	d83f      	bhi.n	3d2c <main@@Base+0x1b30>
    3cac:	4620      	mov	r0, r4
    3cae:	a909      	add	r1, sp, #36	; 0x24
    3cb0:	461a      	mov	r2, r3
    3cb2:	f7ff fcdd 	bl	3670 <main@@Base+0x1474>
    3cb6:	2800      	cmp	r0, #0
    3cb8:	bfb8      	it	lt
    3cba:	f04f 30ff 	movlt.w	r0, #4294967295	; 0xffffffff
    3cbe:	da40      	bge.n	3d42 <main@@Base+0x1b46>
    3cc0:	e036      	b.n	3d30 <main@@Base+0x1b34>
    3cc2:	f8bd 300c 	ldrh.w	r3, [sp, #12]
    3cc6:	42b3      	cmp	r3, r6
    3cc8:	d830      	bhi.n	3d2c <main@@Base+0x1b30>
    3cca:	f8d4 60d8 	ldr.w	r6, [r4, #216]	; 0xd8
    3cce:	f8d4 40dc 	ldr.w	r4, [r4, #220]	; 0xdc
    3cd2:	f7fd ef6c 	blx	1bac <GetRTASGlbCtx@plt>
    3cd6:	9500      	str	r5, [sp, #0]
    3cd8:	ab04      	add	r3, sp, #16
    3cda:	4621      	mov	r1, r4
    3cdc:	6802      	ldr	r2, [r0, #0]
    3cde:	4630      	mov	r0, r6
    3ce0:	9201      	str	r2, [sp, #4]
    3ce2:	2210      	movs	r2, #16
    3ce4:	f7fd ef7c 	blx	1be0 <hu_AESBegin@plt>
    3ce8:	4604      	mov	r4, r0
    3cea:	b990      	cbnz	r0, 3d12 <main@@Base+0x1b16>
    3cec:	682e      	ldr	r6, [r5, #0]
    3cee:	9c08      	ldr	r4, [sp, #32]
    3cf0:	f8bd 500c 	ldrh.w	r5, [sp, #12]
    3cf4:	f7fd ef5a 	blx	1bac <GetRTASGlbCtx@plt>
    3cf8:	4622      	mov	r2, r4
    3cfa:	4629      	mov	r1, r5
    3cfc:	6803      	ldr	r3, [r0, #0]
    3cfe:	4630      	mov	r0, r6
    3d00:	9300      	str	r3, [sp, #0]
    3d02:	4643      	mov	r3, r8
    3d04:	f7fd ef46 	blx	1b94 <hu_AESDecrypt@plt>
    3d08:	4604      	mov	r4, r0
    3d0a:	b910      	cbnz	r0, 3d12 <main@@Base+0x1b16>
    3d0c:	f8bd 300e 	ldrh.w	r3, [sp, #14]
    3d10:	803b      	strh	r3, [r7, #0]
    3d12:	f7fd ef4c 	blx	1bac <GetRTASGlbCtx@plt>
    3d16:	4603      	mov	r3, r0
    3d18:	a802      	add	r0, sp, #8
    3d1a:	6819      	ldr	r1, [r3, #0]
    3d1c:	f7fe ea56 	blx	21cc <hu_AESEnd@plt>
    3d20:	2c00      	cmp	r4, #0
    3d22:	bf0c      	ite	eq
    3d24:	4620      	moveq	r0, r4
    3d26:	f06f 0005 	mvnne.w	r0, #5
    3d2a:	e001      	b.n	3d30 <main@@Base+0x1b34>
    3d2c:	f06f 0005 	mvn.w	r0, #5
    3d30:	f50d 5380 	add.w	r3, sp, #4096	; 0x1000
    3d34:	3324      	adds	r3, #36	; 0x24
    3d36:	681a      	ldr	r2, [r3, #0]
    3d38:	f8d9 3000 	ldr.w	r3, [r9]
    3d3c:	429a      	cmp	r2, r3
    3d3e:	d00b      	beq.n	3d58 <main@@Base+0x1b5c>
    3d40:	e008      	b.n	3d54 <main@@Base+0x1b58>
    3d42:	a809      	add	r0, sp, #36	; 0x24
    3d44:	a903      	add	r1, sp, #12
    3d46:	f7ff ff71 	bl	3c2c <main@@Base+0x1a30>
    3d4a:	f8bd 300e 	ldrh.w	r3, [sp, #14]
    3d4e:	42b3      	cmp	r3, r6
    3d50:	d9b7      	bls.n	3cc2 <main@@Base+0x1ac6>
    3d52:	e7eb      	b.n	3d2c <main@@Base+0x1b30>
    3d54:	f7fe e802 	blx	1d5c <__stack_chk_fail@plt>
    3d58:	b00b      	add	sp, #44	; 0x2c
    3d5a:	f50d 5d80 	add.w	sp, sp, #4096	; 0x1000
    3d5e:	e8bd 83f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, pc}
    3d62:	bf00      	nop
    3d64:	5384      	strh	r4, [r0, r6]
    3d66:	0000      	movs	r0, r0
    3d68:	0258      	lsls	r0, r3, #9
    3d6a:	0000      	movs	r0, r0
    3d6c:	e92d 47f0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, lr}
    3d70:	4699      	mov	r9, r3
    3d72:	4b60      	ldr	r3, [pc, #384]	; (3ef4 <main@@Base+0x1cf8>)
    3d74:	4615      	mov	r5, r2
    3d76:	4a60      	ldr	r2, [pc, #384]	; (3ef8 <main@@Base+0x1cfc>)
    3d78:	b086      	sub	sp, #24
    3d7a:	447b      	add	r3, pc
    3d7c:	460c      	mov	r4, r1
    3d7e:	a903      	add	r1, sp, #12
    3d80:	4607      	mov	r7, r0
    3d82:	f853 a002 	ldr.w	sl, [r3, r2]
    3d86:	2206      	movs	r2, #6
    3d88:	f8da 3000 	ldr.w	r3, [sl]
    3d8c:	9305      	str	r3, [sp, #20]
    3d8e:	f7ff fc6f 	bl	3670 <main@@Base+0x1474>
    3d92:	2800      	cmp	r0, #0
    3d94:	4606      	mov	r6, r0
    3d96:	db0d      	blt.n	3db4 <main@@Base+0x1bb8>
    3d98:	a803      	add	r0, sp, #12
    3d9a:	4621      	mov	r1, r4
    3d9c:	f7ff ff2e 	bl	3bfc <main@@Base+0x1a00>
    3da0:	2800      	cmp	r0, #0
    3da2:	db06      	blt.n	3db2 <main@@Base+0x1bb6>
    3da4:	8823      	ldrh	r3, [r4, #0]
    3da6:	2b03      	cmp	r3, #3
    3da8:	bf98      	it	ls
    3daa:	f06f 0605 	mvnls.w	r6, #5
    3dae:	d901      	bls.n	3db4 <main@@Base+0x1bb8>
    3db0:	e08d      	b.n	3ece <main@@Base+0x1cd2>
    3db2:	4606      	mov	r6, r0
    3db4:	4630      	mov	r0, r6
    3db6:	e084      	b.n	3ec2 <main@@Base+0x1cc6>
    3db8:	4950      	ldr	r1, [pc, #320]	; (3efc <main@@Base+0x1d00>)
    3dba:	2005      	movs	r0, #5
    3dbc:	4479      	add	r1, pc
    3dbe:	f000 f9c3 	bl	4148 <main@@Base+0x1f4c>
    3dc2:	88a3      	ldrh	r3, [r4, #4]
    3dc4:	3b01      	subs	r3, #1
    3dc6:	2b0b      	cmp	r3, #11
    3dc8:	d879      	bhi.n	3ebe <main@@Base+0x1cc2>
    3dca:	e8df f003 	tbb	[pc, r3]
    3dce:	788b      	ldrb	r3, [r1, #2]
    3dd0:	7806      	ldrb	r6, [r0, #0]
    3dd2:	8b2c      	ldrh	r4, [r5, #24]
    3dd4:	8b57      	ldrh	r7, [r2, #26]
    3dd6:	5778      	ldrsb	r0, [r7, r5]
    3dd8:	8b8b      	ldrh	r3, [r1, #28]
    3dda:	f8b4 8000 	ldrh.w	r8, [r4]
    3dde:	f1a8 0806 	sub.w	r8, r8, #6
    3de2:	45c8      	cmp	r8, r9
    3de4:	d87b      	bhi.n	3ede <main@@Base+0x1ce2>
    3de6:	f640 73fa 	movw	r3, #4090	; 0xffa
    3dea:	4598      	cmp	r8, r3
    3dec:	d80a      	bhi.n	3e04 <main@@Base+0x1c08>
    3dee:	f1b8 0f00 	cmp.w	r8, #0
    3df2:	d007      	beq.n	3e04 <main@@Base+0x1c08>
    3df4:	4638      	mov	r0, r7
    3df6:	4629      	mov	r1, r5
    3df8:	4642      	mov	r2, r8
    3dfa:	f7ff fc39 	bl	3670 <main@@Base+0x1474>
    3dfe:	2800      	cmp	r0, #0
    3e00:	db00      	blt.n	3e04 <main@@Base+0x1c08>
    3e02:	d05a      	beq.n	3eba <main@@Base+0x1cbe>
    3e04:	462b      	mov	r3, r5
    3e06:	f833 2b02 	ldrh.w	r2, [r3], #2
    3e0a:	0610      	lsls	r0, r2, #24
    3e0c:	0a12      	lsrs	r2, r2, #8
    3e0e:	60e3      	str	r3, [r4, #12]
    3e10:	ea42 4010 	orr.w	r0, r2, r0, lsr #16
    3e14:	8120      	strh	r0, [r4, #8]
    3e16:	1c82      	adds	r2, r0, #2
    3e18:	4542      	cmp	r2, r8
    3e1a:	bf9c      	itt	ls
    3e1c:	1818      	addls	r0, r3, r0
    3e1e:	ebc5 0000 	rsbls	r0, r5, r0
    3e22:	d948      	bls.n	3eb6 <main@@Base+0x1cba>
    3e24:	e058      	b.n	3ed8 <main@@Base+0x1cdc>
    3e26:	8823      	ldrh	r3, [r4, #0]
    3e28:	f10d 020a 	add.w	r2, sp, #10
    3e2c:	4638      	mov	r0, r7
    3e2e:	9200      	str	r2, [sp, #0]
    3e30:	3b06      	subs	r3, #6
    3e32:	4629      	mov	r1, r5
    3e34:	464a      	mov	r2, r9
    3e36:	f7ff ff17 	bl	3c68 <main@@Base+0x1a6c>
    3e3a:	2800      	cmp	r0, #0
    3e3c:	db41      	blt.n	3ec2 <main@@Base+0x1cc6>
    3e3e:	882b      	ldrh	r3, [r5, #0]
    3e40:	061a      	lsls	r2, r3, #24
    3e42:	0a1b      	lsrs	r3, r3, #8
    3e44:	ea43 4312 	orr.w	r3, r3, r2, lsr #16
    3e48:	8123      	strh	r3, [r4, #8]
    3e4a:	8869      	ldrh	r1, [r5, #2]
    3e4c:	1dab      	adds	r3, r5, #6
    3e4e:	060a      	lsls	r2, r1, #24
    3e50:	0a09      	lsrs	r1, r1, #8
    3e52:	ea41 4212 	orr.w	r2, r1, r2, lsr #16
    3e56:	81a2      	strh	r2, [r4, #12]
    3e58:	88a9      	ldrh	r1, [r5, #4]
    3e5a:	6123      	str	r3, [r4, #16]
    3e5c:	0608      	lsls	r0, r1, #24
    3e5e:	0a09      	lsrs	r1, r1, #8
    3e60:	ea41 4010 	orr.w	r0, r1, r0, lsr #16
    3e64:	81e0      	strh	r0, [r4, #14]
    3e66:	1880      	adds	r0, r0, r2
    3e68:	1899      	adds	r1, r3, r2
    3e6a:	1818      	adds	r0, r3, r0
    3e6c:	f8bd 300a 	ldrh.w	r3, [sp, #10]
    3e70:	1b40      	subs	r0, r0, r5
    3e72:	6161      	str	r1, [r4, #20]
    3e74:	b280      	uxth	r0, r0
    3e76:	4283      	cmp	r3, r0
    3e78:	d21d      	bcs.n	3eb6 <main@@Base+0x1cba>
    3e7a:	e030      	b.n	3ede <main@@Base+0x1ce2>
    3e7c:	8823      	ldrh	r3, [r4, #0]
    3e7e:	f10d 020a 	add.w	r2, sp, #10
    3e82:	4638      	mov	r0, r7
    3e84:	9200      	str	r2, [sp, #0]
    3e86:	3b06      	subs	r3, #6
    3e88:	4629      	mov	r1, r5
    3e8a:	464a      	mov	r2, r9
    3e8c:	f7ff feec 	bl	3c68 <main@@Base+0x1a6c>
    3e90:	2800      	cmp	r0, #0
    3e92:	db16      	blt.n	3ec2 <main@@Base+0x1cc6>
    3e94:	462b      	mov	r3, r5
    3e96:	f833 2b02 	ldrh.w	r2, [r3], #2
    3e9a:	0610      	lsls	r0, r2, #24
    3e9c:	0a12      	lsrs	r2, r2, #8
    3e9e:	60e3      	str	r3, [r4, #12]
    3ea0:	ea42 4010 	orr.w	r0, r2, r0, lsr #16
    3ea4:	8120      	strh	r0, [r4, #8]
    3ea6:	1818      	adds	r0, r3, r0
    3ea8:	f8bd 300a 	ldrh.w	r3, [sp, #10]
    3eac:	1b40      	subs	r0, r0, r5
    3eae:	b280      	uxth	r0, r0
    3eb0:	4283      	cmp	r3, r0
    3eb2:	d314      	bcc.n	3ede <main@@Base+0x1ce2>
    3eb4:	e001      	b.n	3eba <main@@Base+0x1cbe>
    3eb6:	2800      	cmp	r0, #0
    3eb8:	db03      	blt.n	3ec2 <main@@Base+0x1cc6>
    3eba:	1980      	adds	r0, r0, r6
    3ebc:	e001      	b.n	3ec2 <main@@Base+0x1cc6>
    3ebe:	f06f 0002 	mvn.w	r0, #2
    3ec2:	9a05      	ldr	r2, [sp, #20]
    3ec4:	f8da 3000 	ldr.w	r3, [sl]
    3ec8:	429a      	cmp	r2, r3
    3eca:	d00f      	beq.n	3eec <main@@Base+0x1cf0>
    3ecc:	e00c      	b.n	3ee8 <main@@Base+0x1cec>
    3ece:	88a2      	ldrh	r2, [r4, #4]
    3ed0:	2a06      	cmp	r2, #6
    3ed2:	f47f af71 	bne.w	3db8 <main@@Base+0x1bbc>
    3ed6:	e774      	b.n	3dc2 <main@@Base+0x1bc6>
    3ed8:	f06f 0003 	mvn.w	r0, #3
    3edc:	e7f1      	b.n	3ec2 <main@@Base+0x1cc6>
    3ede:	f06f 0005 	mvn.w	r0, #5
    3ee2:	e7ee      	b.n	3ec2 <main@@Base+0x1cc6>
    3ee4:	2000      	movs	r0, #0
    3ee6:	e7e8      	b.n	3eba <main@@Base+0x1cbe>
    3ee8:	f7fd ef38 	blx	1d5c <__stack_chk_fail@plt>
    3eec:	b006      	add	sp, #24
    3eee:	e8bd 87f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, pc}
    3ef2:	bf00      	nop
    3ef4:	5282      	strh	r2, [r0, r2]
    3ef6:	0000      	movs	r0, r0
    3ef8:	0258      	lsls	r0, r3, #9
    3efa:	0000      	movs	r0, r0
    3efc:	23ac      	movs	r3, #172	; 0xac
    3efe:	0000      	movs	r0, r0
    3f00:	4b4c      	ldr	r3, [pc, #304]	; (4034 <main@@Base+0x1e38>)
    3f02:	2100      	movs	r1, #0
    3f04:	4a4c      	ldr	r2, [pc, #304]	; (4038 <main@@Base+0x1e3c>)
    3f06:	447b      	add	r3, pc
    3f08:	b570      	push	{r4, r5, r6, lr}
    3f0a:	f5ad 5d89 	sub.w	sp, sp, #4384	; 0x1120
    3f0e:	589d      	ldr	r5, [r3, r2]
    3f10:	f50d 5288 	add.w	r2, sp, #4352	; 0x1100
    3f14:	321c      	adds	r2, #28
    3f16:	4604      	mov	r4, r0
    3f18:	a807      	add	r0, sp, #28
    3f1a:	2610      	movs	r6, #16
    3f1c:	682b      	ldr	r3, [r5, #0]
    3f1e:	9606      	str	r6, [sp, #24]
    3f20:	6013      	str	r3, [r2, #0]
    3f22:	f44f 5280 	mov.w	r2, #4096	; 0x1000
    3f26:	f7fd ef58 	blx	1dd8 <memset@plt+0x4>
    3f2a:	f50d 5080 	add.w	r0, sp, #4096	; 0x1000
    3f2e:	2100      	movs	r1, #0
    3f30:	301c      	adds	r0, #28
    3f32:	f44f 7280 	mov.w	r2, #256	; 0x100
    3f36:	f7fd ef50 	blx	1dd8 <memset@plt+0x4>
    3f3a:	f104 01fc 	add.w	r1, r4, #252	; 0xfc
    3f3e:	6820      	ldr	r0, [r4, #0]
    3f40:	aa06      	add	r2, sp, #24
    3f42:	f7fe e89a 	blx	2078 <accept@plt>
    3f46:	2800      	cmp	r0, #0
    3f48:	60a0      	str	r0, [r4, #8]
    3f4a:	da0b      	bge.n	3f64 <main@@Base+0x1d68>
    3f4c:	f7fd ee60 	blx	1c10 <__get_errno_ptr@plt>
    3f50:	6800      	ldr	r0, [r0, #0]
    3f52:	f7fd ee64 	blx	1c1c <strerror@plt>
    3f56:	4939      	ldr	r1, [pc, #228]	; (403c <main@@Base+0x1e40>)
    3f58:	4479      	add	r1, pc
    3f5a:	4602      	mov	r2, r0
    3f5c:	2002      	movs	r0, #2
    3f5e:	f000 f8f3 	bl	4148 <main@@Base+0x1f4c>
    3f62:	e00c      	b.n	3f7e <main@@Base+0x1d82>
    3f64:	f504 7186 	add.w	r1, r4, #268	; 0x10c
    3f68:	aa06      	add	r2, sp, #24
    3f6a:	9606      	str	r6, [sp, #24]
    3f6c:	f7fd ef5e 	blx	1e2c <getsockname@plt>
    3f70:	2800      	cmp	r0, #0
    3f72:	da07      	bge.n	3f84 <main@@Base+0x1d88>
    3f74:	4932      	ldr	r1, [pc, #200]	; (4040 <main@@Base+0x1e44>)
    3f76:	2002      	movs	r0, #2
    3f78:	4479      	add	r1, pc
    3f7a:	f000 f8e5 	bl	4148 <main@@Base+0x1f4c>
    3f7e:	f04f 36ff 	mov.w	r6, #4294967295	; 0xffffffff
    3f82:	e049      	b.n	4018 <main@@Base+0x1e1c>
    3f84:	f44f 5380 	mov.w	r3, #4096	; 0x1000
    3f88:	4620      	mov	r0, r4
    3f8a:	4669      	mov	r1, sp
    3f8c:	aa07      	add	r2, sp, #28
    3f8e:	f7ff feed 	bl	3d6c <main@@Base+0x1b70>
    3f92:	1c83      	adds	r3, r0, #2
    3f94:	4606      	mov	r6, r0
    3f96:	d110      	bne.n	3fba <main@@Base+0x1dbe>
    3f98:	492a      	ldr	r1, [pc, #168]	; (4044 <main@@Base+0x1e48>)
    3f9a:	f50d 5080 	add.w	r0, sp, #4096	; 0x1000
    3f9e:	2202      	movs	r2, #2
    3fa0:	301c      	adds	r0, #28
    3fa2:	4479      	add	r1, pc
    3fa4:	f7fe e8aa 	blx	20fc <sprintf@plt>
    3fa8:	f50d 5380 	add.w	r3, sp, #4096	; 0x1000
    3fac:	4620      	mov	r0, r4
    3fae:	2101      	movs	r1, #1
    3fb0:	220a      	movs	r2, #10
    3fb2:	331c      	adds	r3, #28
    3fb4:	f7ff fd51 	bl	3a5a <main@@Base+0x185e>
    3fb8:	e017      	b.n	3fea <main@@Base+0x1dee>
    3fba:	2800      	cmp	r0, #0
    3fbc:	da06      	bge.n	3fcc <main@@Base+0x1dd0>
    3fbe:	f7ff fc66 	bl	388e <main@@Base+0x1692>
    3fc2:	4921      	ldr	r1, [pc, #132]	; (4048 <main@@Base+0x1e4c>)
    3fc4:	4479      	add	r1, pc
    3fc6:	4602      	mov	r2, r0
    3fc8:	2002      	movs	r0, #2
    3fca:	e020      	b.n	400e <main@@Base+0x1e12>
    3fcc:	f8bd 2004 	ldrh.w	r2, [sp, #4]
    3fd0:	2a01      	cmp	r2, #1
    3fd2:	d00a      	beq.n	3fea <main@@Base+0x1dee>
    3fd4:	491d      	ldr	r1, [pc, #116]	; (404c <main@@Base+0x1e50>)
    3fd6:	2002      	movs	r0, #2
    3fd8:	f06f 0604 	mvn.w	r6, #4
    3fdc:	4479      	add	r1, pc
    3fde:	f000 f8b3 	bl	4148 <main@@Base+0x1f4c>
    3fe2:	68a0      	ldr	r0, [r4, #8]
    3fe4:	f7fd edea 	blx	1bbc <close@plt+0x4>
    3fe8:	e016      	b.n	4018 <main@@Base+0x1e1c>
    3fea:	2200      	movs	r2, #0
    3fec:	2101      	movs	r1, #1
    3fee:	4620      	mov	r0, r4
    3ff0:	4613      	mov	r3, r2
    3ff2:	f7ff fd32 	bl	3a5a <main@@Base+0x185e>
    3ff6:	2800      	cmp	r0, #0
    3ff8:	4606      	mov	r6, r0
    3ffa:	bfa8      	it	ge
    3ffc:	68a6      	ldrge	r6, [r4, #8]
    3ffe:	da0b      	bge.n	4018 <main@@Base+0x1e1c>
    4000:	4630      	mov	r0, r6
    4002:	f7ff fc44 	bl	388e <main@@Base+0x1692>
    4006:	4912      	ldr	r1, [pc, #72]	; (4050 <main@@Base+0x1e54>)
    4008:	4479      	add	r1, pc
    400a:	4602      	mov	r2, r0
    400c:	2002      	movs	r0, #2
    400e:	f000 f89b 	bl	4148 <main@@Base+0x1f4c>
    4012:	68a0      	ldr	r0, [r4, #8]
    4014:	f7fd edd2 	blx	1bbc <close@plt+0x4>
    4018:	f50d 5388 	add.w	r3, sp, #4352	; 0x1100
    401c:	4630      	mov	r0, r6
    401e:	331c      	adds	r3, #28
    4020:	681a      	ldr	r2, [r3, #0]
    4022:	682b      	ldr	r3, [r5, #0]
    4024:	429a      	cmp	r2, r3
    4026:	d001      	beq.n	402c <main@@Base+0x1e30>
    4028:	f7fd ee98 	blx	1d5c <__stack_chk_fail@plt>
    402c:	b048      	add	sp, #288	; 0x120
    402e:	f50d 5d80 	add.w	sp, sp, #4096	; 0x1000
    4032:	bd70      	pop	{r4, r5, r6, pc}
    4034:	50f6      	str	r6, [r6, r3]
    4036:	0000      	movs	r0, r0
    4038:	0258      	lsls	r0, r3, #9
    403a:	0000      	movs	r0, r0
    403c:	2224      	movs	r2, #36	; 0x24
    403e:	0000      	movs	r0, r0
    4040:	2227      	movs	r2, #39	; 0x27
    4042:	0000      	movs	r0, r0
    4044:	2238      	movs	r2, #56	; 0x38
    4046:	0000      	movs	r0, r0
    4048:	2245      	movs	r2, #69	; 0x45
    404a:	0000      	movs	r0, r0
    404c:	2255      	movs	r2, #85	; 0x55
    404e:	0000      	movs	r0, r0
    4050:	2253      	movs	r2, #83	; 0x53
    4052:	0000      	movs	r0, r0
    4054:	4b31      	ldr	r3, [pc, #196]	; (411c <main@@Base+0x1f20>)
    4056:	4a32      	ldr	r2, [pc, #200]	; (4120 <main@@Base+0x1f24>)
    4058:	447b      	add	r3, pc
    405a:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
    405e:	b085      	sub	sp, #20
    4060:	589c      	ldr	r4, [r3, r2]
    4062:	4681      	mov	r9, r0
    4064:	a802      	add	r0, sp, #8
    4066:	6823      	ldr	r3, [r4, #0]
    4068:	9303      	str	r3, [sp, #12]
    406a:	f7fe e88c 	blx	2184 <getifaddrs@plt>
    406e:	9401      	str	r4, [sp, #4]
    4070:	b168      	cbz	r0, 408e <main@@Base+0x1e92>
    4072:	f7fd edce 	blx	1c10 <__get_errno_ptr@plt>
    4076:	f04f 34ff 	mov.w	r4, #4294967295	; 0xffffffff
    407a:	6800      	ldr	r0, [r0, #0]
    407c:	f7fd edce 	blx	1c1c <strerror@plt>
    4080:	4928      	ldr	r1, [pc, #160]	; (4124 <main@@Base+0x1f28>)
    4082:	4479      	add	r1, pc
    4084:	4602      	mov	r2, r0
    4086:	2002      	movs	r0, #2
    4088:	f000 f85e 	bl	4148 <main@@Base+0x1f4c>
    408c:	e03a      	b.n	4104 <main@@Base+0x1f08>
    408e:	9e02      	ldr	r6, [sp, #8]
    4090:	f06f 040a 	mvn.w	r4, #10
    4094:	f8df 8090 	ldr.w	r8, [pc, #144]	; 4128 <main@@Base+0x1f2c>
    4098:	f109 0904 	add.w	r9, r9, #4
    409c:	4f23      	ldr	r7, [pc, #140]	; (412c <main@@Base+0x1f30>)
    409e:	f8df a090 	ldr.w	sl, [pc, #144]	; 4130 <main@@Base+0x1f34>
    40a2:	4635      	mov	r5, r6
    40a4:	f8df b08c 	ldr.w	fp, [pc, #140]	; 4134 <main@@Base+0x1f38>
    40a8:	44f8      	add	r8, pc
    40aa:	447f      	add	r7, pc
    40ac:	44fa      	add	sl, pc
    40ae:	44fb      	add	fp, pc
    40b0:	e020      	b.n	40f4 <main@@Base+0x1ef8>
    40b2:	68e8      	ldr	r0, [r5, #12]
    40b4:	7843      	ldrb	r3, [r0, #1]
    40b6:	2b02      	cmp	r3, #2
    40b8:	d11b      	bne.n	40f2 <main@@Base+0x1ef6>
    40ba:	3004      	adds	r0, #4
    40bc:	4649      	mov	r1, r9
    40be:	2204      	movs	r2, #4
    40c0:	f7fd efa4 	blx	200c <memcmp@plt+0x4>
    40c4:	b9a8      	cbnz	r0, 40f2 <main@@Base+0x1ef6>
    40c6:	686c      	ldr	r4, [r5, #4]
    40c8:	4641      	mov	r1, r8
    40ca:	4620      	mov	r0, r4
    40cc:	f7fe e88a 	blx	21e4 <strcmp@plt>
    40d0:	b170      	cbz	r0, 40f0 <main@@Base+0x1ef4>
    40d2:	4620      	mov	r0, r4
    40d4:	4639      	mov	r1, r7
    40d6:	f7fe e886 	blx	21e4 <strcmp@plt>
    40da:	b148      	cbz	r0, 40f0 <main@@Base+0x1ef4>
    40dc:	4620      	mov	r0, r4
    40de:	4651      	mov	r1, sl
    40e0:	f7fe e880 	blx	21e4 <strcmp@plt>
    40e4:	b120      	cbz	r0, 40f0 <main@@Base+0x1ef4>
    40e6:	4620      	mov	r0, r4
    40e8:	4659      	mov	r1, fp
    40ea:	f7fe e87c 	blx	21e4 <strcmp@plt>
    40ee:	b920      	cbnz	r0, 40fa <main@@Base+0x1efe>
    40f0:	4604      	mov	r4, r0
    40f2:	682d      	ldr	r5, [r5, #0]
    40f4:	2d00      	cmp	r5, #0
    40f6:	d1dc      	bne.n	40b2 <main@@Base+0x1eb6>
    40f8:	e001      	b.n	40fe <main@@Base+0x1f02>
    40fa:	f06f 040a 	mvn.w	r4, #10
    40fe:	4630      	mov	r0, r6
    4100:	f7fd eeb8 	blx	1e74 <freeifaddrs@plt>
    4104:	9901      	ldr	r1, [sp, #4]
    4106:	4620      	mov	r0, r4
    4108:	9a03      	ldr	r2, [sp, #12]
    410a:	680b      	ldr	r3, [r1, #0]
    410c:	429a      	cmp	r2, r3
    410e:	d001      	beq.n	4114 <main@@Base+0x1f18>
    4110:	f7fd ee24 	blx	1d5c <__stack_chk_fail@plt>
    4114:	b005      	add	sp, #20
    4116:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
    411a:	bf00      	nop
    411c:	4fa4      	ldr	r7, [pc, #656]	; (43b0 <main@@Base+0x21b4>)
    411e:	0000      	movs	r0, r0
    4120:	0258      	lsls	r0, r3, #9
    4122:	0000      	movs	r0, r0
    4124:	21fa      	movs	r1, #250	; 0xfa
    4126:	0000      	movs	r0, r0
    4128:	21f9      	movs	r1, #249	; 0xf9
    412a:	0000      	movs	r0, r0
    412c:	21fc      	movs	r1, #252	; 0xfc
    412e:	0000      	movs	r0, r0
    4130:	2201      	movs	r2, #1
    4132:	0000      	movs	r0, r0
    4134:	2205      	movs	r2, #5
    4136:	0000      	movs	r0, r0
    4138:	4b02      	ldr	r3, [pc, #8]	; (4144 <main@@Base+0x1f48>)
    413a:	447b      	add	r3, pc
    413c:	f853 0020 	ldr.w	r0, [r3, r0, lsl #2]
    4140:	4770      	bx	lr
    4142:	bf00      	nop
    4144:	514a      	str	r2, [r1, r5]
    4146:	0000      	movs	r0, r0
    4148:	b40e      	push	{r1, r2, r3}
    414a:	4921      	ldr	r1, [pc, #132]	; (41d0 <main@@Base+0x1fd4>)
    414c:	b530      	push	{r4, r5, lr}
    414e:	4604      	mov	r4, r0
    4150:	4820      	ldr	r0, [pc, #128]	; (41d4 <main@@Base+0x1fd8>)
    4152:	4479      	add	r1, pc
    4154:	b0c4      	sub	sp, #272	; 0x110
    4156:	ab47      	add	r3, sp, #284	; 0x11c
    4158:	580d      	ldr	r5, [r1, r0]
    415a:	a803      	add	r0, sp, #12
    415c:	f853 2b04 	ldr.w	r2, [r3], #4
    4160:	6829      	ldr	r1, [r5, #0]
    4162:	9302      	str	r3, [sp, #8]
    4164:	9143      	str	r1, [sp, #268]	; 0x10c
    4166:	f44f 7180 	mov.w	r1, #256	; 0x100
    416a:	f7fd eec0 	blx	1eec <vsnprintf@plt>
    416e:	1e63      	subs	r3, r4, #1
    4170:	2b05      	cmp	r3, #5
    4172:	d810      	bhi.n	4196 <main@@Base+0x1f9a>
    4174:	e8df f003 	tbb	[pc, r3]
    4178:	1203      	asrs	r3, r0, #8
    417a:	0f06      	lsrs	r6, r0, #28
    417c:	0c09      	lsrs	r1, r1, #16
    417e:	4b16      	ldr	r3, [pc, #88]	; (41d8 <main@@Base+0x1fdc>)
    4180:	447b      	add	r3, pc
    4182:	e00d      	b.n	41a0 <main@@Base+0x1fa4>
    4184:	4b15      	ldr	r3, [pc, #84]	; (41dc <main@@Base+0x1fe0>)
    4186:	447b      	add	r3, pc
    4188:	e00a      	b.n	41a0 <main@@Base+0x1fa4>
    418a:	4b15      	ldr	r3, [pc, #84]	; (41e0 <main@@Base+0x1fe4>)
    418c:	447b      	add	r3, pc
    418e:	e007      	b.n	41a0 <main@@Base+0x1fa4>
    4190:	4b14      	ldr	r3, [pc, #80]	; (41e4 <main@@Base+0x1fe8>)
    4192:	447b      	add	r3, pc
    4194:	e004      	b.n	41a0 <main@@Base+0x1fa4>
    4196:	4b14      	ldr	r3, [pc, #80]	; (41e8 <main@@Base+0x1fec>)
    4198:	447b      	add	r3, pc
    419a:	e001      	b.n	41a0 <main@@Base+0x1fa4>
    419c:	4b13      	ldr	r3, [pc, #76]	; (41ec <main@@Base+0x1ff0>)
    419e:	447b      	add	r3, pc
    41a0:	9300      	str	r3, [sp, #0]
    41a2:	ab03      	add	r3, sp, #12
    41a4:	4a12      	ldr	r2, [pc, #72]	; (41f0 <main@@Base+0x1ff4>)
    41a6:	4621      	mov	r1, r4
    41a8:	9301      	str	r3, [sp, #4]
    41aa:	4b12      	ldr	r3, [pc, #72]	; (41f4 <main@@Base+0x1ff8>)
    41ac:	447a      	add	r2, pc
    41ae:	4807      	ldr	r0, [pc, #28]	; (41cc <main@@Base+0x1fd0>)
    41b0:	447b      	add	r3, pc
    41b2:	f7fd edf8 	blx	1da4 <slogf@plt>
    41b6:	9a43      	ldr	r2, [sp, #268]	; 0x10c
    41b8:	682b      	ldr	r3, [r5, #0]
    41ba:	429a      	cmp	r2, r3
    41bc:	d001      	beq.n	41c2 <main@@Base+0x1fc6>
    41be:	f7fd edce 	blx	1d5c <__stack_chk_fail@plt>
    41c2:	b044      	add	sp, #272	; 0x110
    41c4:	e8bd 4030 	ldmia.w	sp!, {r4, r5, lr}
    41c8:	b003      	add	sp, #12
    41ca:	4770      	bx	lr
    41cc:	2719      	movs	r7, #25
    41ce:	0010      	movs	r0, r2
    41d0:	4eaa      	ldr	r6, [pc, #680]	; (447c <main@@Base+0x2280>)
    41d2:	0000      	movs	r0, r0
    41d4:	0258      	lsls	r0, r3, #9
    41d6:	0000      	movs	r0, r0
    41d8:	214a      	movs	r1, #74	; 0x4a
    41da:	0000      	movs	r0, r0
    41dc:	2153      	movs	r1, #83	; 0x53
    41de:	0000      	movs	r0, r0
    41e0:	2155      	movs	r1, #85	; 0x55
    41e2:	0000      	movs	r0, r0
    41e4:	2154      	movs	r1, #84	; 0x54
    41e6:	0000      	movs	r0, r0
    41e8:	2154      	movs	r1, #84	; 0x54
    41ea:	0000      	movs	r0, r0
    41ec:	2135      	movs	r1, #53	; 0x35
    41ee:	0000      	movs	r0, r0
    41f0:	214c      	movs	r1, #76	; 0x4c
    41f2:	0000      	movs	r0, r0
    41f4:	2153      	movs	r1, #83	; 0x53
    41f6:	0000      	movs	r0, r0
    41f8:	2811      	cmp	r0, #17
    41fa:	d803      	bhi.n	4204 <main@@Base+0x2008>
    41fc:	4b03      	ldr	r3, [pc, #12]	; (420c <main@@Base+0x2010>)
    41fe:	447b      	add	r3, pc
    4200:	5618      	ldrsb	r0, [r3, r0]
    4202:	4770      	bx	lr
    4204:	f04f 30ff 	mov.w	r0, #4294967295	; 0xffffffff
    4208:	4770      	bx	lr
    420a:	bf00      	nop
    420c:	20ba      	movs	r0, #186	; 0xba
    420e:	0000      	movs	r0, r0
    4210:	4b24      	ldr	r3, [pc, #144]	; (42a4 <main@@Base+0x20a8>)
    4212:	4a25      	ldr	r2, [pc, #148]	; (42a8 <main@@Base+0x20ac>)
    4214:	447b      	add	r3, pc
    4216:	b530      	push	{r4, r5, lr}
    4218:	b08d      	sub	sp, #52	; 0x34
    421a:	589c      	ldr	r4, [r3, r2]
    421c:	2500      	movs	r5, #0
    421e:	9007      	str	r0, [sp, #28]
    4220:	a803      	add	r0, sp, #12
    4222:	9508      	str	r5, [sp, #32]
    4224:	6823      	ldr	r3, [r4, #0]
    4226:	930b      	str	r3, [sp, #44]	; 0x2c
    4228:	4b20      	ldr	r3, [pc, #128]	; (42ac <main@@Base+0x20b0>)
    422a:	447b      	add	r3, pc
    422c:	9304      	str	r3, [sp, #16]
    422e:	4b20      	ldr	r3, [pc, #128]	; (42b0 <main@@Base+0x20b4>)
    4230:	447b      	add	r3, pc
    4232:	9305      	str	r3, [sp, #20]
    4234:	4b1f      	ldr	r3, [pc, #124]	; (42b4 <main@@Base+0x20b8>)
    4236:	447b      	add	r3, pc
    4238:	9306      	str	r3, [sp, #24]
    423a:	f7fd ec9a 	blx	1b70 <posix_spawnattr_init@plt>
    423e:	f44f 2100 	mov.w	r1, #524288	; 0x80000
    4242:	a803      	add	r0, sp, #12
    4244:	f7fd ed2e 	blx	1ca4 <posix_spawnattr_setxflags@plt>
    4248:	4629      	mov	r1, r5
    424a:	aa09      	add	r2, sp, #36	; 0x24
    424c:	4628      	mov	r0, r5
    424e:	f7fd eca8 	blx	1ba0 <pthread_sigmask@plt>
    4252:	a909      	add	r1, sp, #36	; 0x24
    4254:	a803      	add	r0, sp, #12
    4256:	f7fd ed02 	blx	1c5c <posix_spawnattr_setsigmask@plt>
    425a:	4629      	mov	r1, r5
    425c:	462a      	mov	r2, r5
    425e:	a803      	add	r0, sp, #12
    4260:	f7fd ed5e 	blx	1d20 <posix_spawnattr_setcred@plt>
    4264:	ab04      	add	r3, sp, #16
    4266:	462a      	mov	r2, r5
    4268:	e88d 0028 	stmia.w	sp, {r3, r5}
    426c:	a802      	add	r0, sp, #8
    426e:	9904      	ldr	r1, [sp, #16]
    4270:	ab03      	add	r3, sp, #12
    4272:	f7fd ed92 	blx	1d98 <posix_spawn@plt>
    4276:	4605      	mov	r5, r0
    4278:	a803      	add	r0, sp, #12
    427a:	f7fd ee80 	blx	1f7c <posix_spawnattr_destroy@plt>
    427e:	b125      	cbz	r5, 428a <main@@Base+0x208e>
    4280:	490d      	ldr	r1, [pc, #52]	; (42b8 <main@@Base+0x20bc>)
    4282:	2002      	movs	r0, #2
    4284:	4479      	add	r1, pc
    4286:	f7ff ff5f 	bl	4148 <main@@Base+0x1f4c>
    428a:	2100      	movs	r1, #0
    428c:	9802      	ldr	r0, [sp, #8]
    428e:	460a      	mov	r2, r1
    4290:	f7fd ed26 	blx	1ce0 <waitpid@plt>
    4294:	9a0b      	ldr	r2, [sp, #44]	; 0x2c
    4296:	6823      	ldr	r3, [r4, #0]
    4298:	429a      	cmp	r2, r3
    429a:	d001      	beq.n	42a0 <main@@Base+0x20a4>
    429c:	f7fd ed5e 	blx	1d5c <__stack_chk_fail@plt>
    42a0:	b00d      	add	sp, #52	; 0x34
    42a2:	bd30      	pop	{r4, r5, pc}
    42a4:	4de8      	ldr	r5, [pc, #928]	; (4648 <main@@Base+0x244c>)
    42a6:	0000      	movs	r0, r0
    42a8:	0258      	lsls	r0, r3, #9
    42aa:	0000      	movs	r0, r0
    42ac:	24a3      	movs	r4, #163	; 0xa3
    42ae:	0000      	movs	r0, r0
    42b0:	24a7      	movs	r4, #167	; 0xa7
    42b2:	0000      	movs	r0, r0
    42b4:	24a5      	movs	r4, #165	; 0xa5
    42b6:	0000      	movs	r0, r0
    42b8:	245f      	movs	r4, #95	; 0x5f
    42ba:	0000      	movs	r0, r0
    42bc:	b510      	push	{r4, lr}
    42be:	4604      	mov	r4, r0
    42c0:	b920      	cbnz	r0, 42cc <main@@Base+0x20d0>
    42c2:	490c      	ldr	r1, [pc, #48]	; (42f4 <main@@Base+0x20f8>)
    42c4:	2002      	movs	r0, #2
    42c6:	4479      	add	r1, pc
    42c8:	f7ff ff3e 	bl	4148 <main@@Base+0x1f4c>
    42cc:	6822      	ldr	r2, [r4, #0]
    42ce:	b932      	cbnz	r2, 42de <main@@Base+0x20e2>
    42d0:	6860      	ldr	r0, [r4, #4]
    42d2:	b108      	cbz	r0, 42d8 <main@@Base+0x20dc>
    42d4:	f7fd ed10 	blx	1cf8 <RSA_free@plt>
    42d8:	2300      	movs	r3, #0
    42da:	6063      	str	r3, [r4, #4]
    42dc:	e004      	b.n	42e8 <main@@Base+0x20ec>
    42de:	4906      	ldr	r1, [pc, #24]	; (42f8 <main@@Base+0x20fc>)
    42e0:	2002      	movs	r0, #2
    42e2:	4479      	add	r1, pc
    42e4:	f7ff ff30 	bl	4148 <main@@Base+0x1f4c>
    42e8:	4620      	mov	r0, r4
    42ea:	e8bd 4010 	ldmia.w	sp!, {r4, lr}
    42ee:	f7fd bc9b 	b.w	1c28 <free@plt>
    42f2:	bf00      	nop
    42f4:	243c      	movs	r4, #60	; 0x3c
    42f6:	0000      	movs	r0, r0
    42f8:	2436      	movs	r4, #54	; 0x36
    42fa:	0000      	movs	r0, r0
    42fc:	b538      	push	{r3, r4, r5, lr}
    42fe:	4604      	mov	r4, r0
    4300:	4615      	mov	r5, r2
    4302:	68e3      	ldr	r3, [r4, #12]
    4304:	68a2      	ldr	r2, [r4, #8]
    4306:	4608      	mov	r0, r1
    4308:	1a9b      	subs	r3, r3, r2
    430a:	429d      	cmp	r5, r3
    430c:	d908      	bls.n	4320 <main@@Base+0x2124>
    430e:	4909      	ldr	r1, [pc, #36]	; (4334 <main@@Base+0x2138>)
    4310:	2002      	movs	r0, #2
    4312:	462a      	mov	r2, r5
    4314:	4479      	add	r1, pc
    4316:	f7ff ff17 	bl	4148 <main@@Base+0x1f4c>
    431a:	f04f 30ff 	mov.w	r0, #4294967295	; 0xffffffff
    431e:	bd38      	pop	{r3, r4, r5, pc}
    4320:	6821      	ldr	r1, [r4, #0]
    4322:	1889      	adds	r1, r1, r2
    4324:	462a      	mov	r2, r5
    4326:	f7fd ecf0 	blx	1d08 <memcpy@plt+0x4>
    432a:	68a3      	ldr	r3, [r4, #8]
    432c:	2000      	movs	r0, #0
    432e:	195d      	adds	r5, r3, r5
    4330:	60a5      	str	r5, [r4, #8]
    4332:	bd38      	pop	{r3, r4, r5, pc}
    4334:	241e      	movs	r4, #30
    4336:	0000      	movs	r0, r0
    4338:	4b29      	ldr	r3, [pc, #164]	; (43e0 <main@@Base+0x21e4>)
    433a:	4a2a      	ldr	r2, [pc, #168]	; (43e4 <main@@Base+0x21e8>)
    433c:	447b      	add	r3, pc
    433e:	e92d 41f3 	stmdb	sp!, {r0, r1, r4, r5, r6, r7, r8, lr}
    4342:	460e      	mov	r6, r1
    4344:	589c      	ldr	r4, [r3, r2]
    4346:	4669      	mov	r1, sp
    4348:	2204      	movs	r2, #4
    434a:	4607      	mov	r7, r0
    434c:	6823      	ldr	r3, [r4, #0]
    434e:	46a0      	mov	r8, r4
    4350:	9301      	str	r3, [sp, #4]
    4352:	f7ff ffd3 	bl	42fc <main@@Base+0x2100>
    4356:	3001      	adds	r0, #1
    4358:	d011      	beq.n	437e <main@@Base+0x2182>
    435a:	f89d 5001 	ldrb.w	r5, [sp, #1]
    435e:	f89d 3000 	ldrb.w	r3, [sp]
    4362:	042d      	lsls	r5, r5, #16
    4364:	ea45 6503 	orr.w	r5, r5, r3, lsl #24
    4368:	f89d 3003 	ldrb.w	r3, [sp, #3]
    436c:	431d      	orrs	r5, r3
    436e:	f89d 3002 	ldrb.w	r3, [sp, #2]
    4372:	ea45 2503 	orr.w	r5, r5, r3, lsl #8
    4376:	f5b5 2f80 	cmp.w	r5, #262144	; 0x40000
    437a:	d90e      	bls.n	439a <main@@Base+0x219e>
    437c:	e005      	b.n	438a <main@@Base+0x218e>
    437e:	491a      	ldr	r1, [pc, #104]	; (43e8 <main@@Base+0x21ec>)
    4380:	2002      	movs	r0, #2
    4382:	4479      	add	r1, pc
    4384:	f7ff fee0 	bl	4148 <main@@Base+0x1f4c>
    4388:	e005      	b.n	4396 <main@@Base+0x219a>
    438a:	4918      	ldr	r1, [pc, #96]	; (43ec <main@@Base+0x21f0>)
    438c:	2002      	movs	r0, #2
    438e:	462a      	mov	r2, r5
    4390:	4479      	add	r1, pc
    4392:	f7ff fed9 	bl	4148 <main@@Base+0x1f4c>
    4396:	2400      	movs	r4, #0
    4398:	e017      	b.n	43ca <main@@Base+0x21ce>
    439a:	1c68      	adds	r0, r5, #1
    439c:	f7fd ef1c 	blx	21d8 <malloc@plt>
    43a0:	462a      	mov	r2, r5
    43a2:	4604      	mov	r4, r0
    43a4:	4638      	mov	r0, r7
    43a6:	4621      	mov	r1, r4
    43a8:	f7ff ffa8 	bl	42fc <main@@Base+0x2100>
    43ac:	3001      	adds	r0, #1
    43ae:	d108      	bne.n	43c2 <main@@Base+0x21c6>
    43b0:	490f      	ldr	r1, [pc, #60]	; (43f0 <main@@Base+0x21f4>)
    43b2:	2002      	movs	r0, #2
    43b4:	4479      	add	r1, pc
    43b6:	f7ff fec7 	bl	4148 <main@@Base+0x1f4c>
    43ba:	4620      	mov	r0, r4
    43bc:	f7fd ec36 	blx	1c2c <free@plt+0x4>
    43c0:	e7e9      	b.n	4396 <main@@Base+0x219a>
    43c2:	2300      	movs	r3, #0
    43c4:	5563      	strb	r3, [r4, r5]
    43c6:	b106      	cbz	r6, 43ca <main@@Base+0x21ce>
    43c8:	6035      	str	r5, [r6, #0]
    43ca:	9a01      	ldr	r2, [sp, #4]
    43cc:	4620      	mov	r0, r4
    43ce:	f8d8 3000 	ldr.w	r3, [r8]
    43d2:	429a      	cmp	r2, r3
    43d4:	d001      	beq.n	43da <main@@Base+0x21de>
    43d6:	f7fd ecc2 	blx	1d5c <__stack_chk_fail@plt>
    43da:	e8bd 81fc 	ldmia.w	sp!, {r2, r3, r4, r5, r6, r7, r8, pc}
    43de:	bf00      	nop
    43e0:	4cc0      	ldr	r4, [pc, #768]	; (46e4 <main@@Base+0x24e8>)
    43e2:	0000      	movs	r0, r0
    43e4:	0258      	lsls	r0, r3, #9
    43e6:	0000      	movs	r0, r0
    43e8:	23ee      	movs	r3, #238	; 0xee
    43ea:	0000      	movs	r0, r0
    43ec:	240d      	movs	r4, #13
    43ee:	0000      	movs	r0, r0
    43f0:	2415      	movs	r4, #21
    43f2:	0000      	movs	r0, r0
    43f4:	4b20      	ldr	r3, [pc, #128]	; (4478 <main@@Base+0x227c>)
    43f6:	4a21      	ldr	r2, [pc, #132]	; (447c <main@@Base+0x2280>)
    43f8:	447b      	add	r3, pc
    43fa:	b573      	push	{r0, r1, r4, r5, r6, lr}
    43fc:	460e      	mov	r6, r1
    43fe:	589d      	ldr	r5, [r3, r2]
    4400:	4669      	mov	r1, sp
    4402:	682b      	ldr	r3, [r5, #0]
    4404:	9301      	str	r3, [sp, #4]
    4406:	f7ff ff97 	bl	4338 <main@@Base+0x213c>
    440a:	4604      	mov	r4, r0
    440c:	b928      	cbnz	r0, 441a <main@@Base+0x221e>
    440e:	491c      	ldr	r1, [pc, #112]	; (4480 <main@@Base+0x2284>)
    4410:	2002      	movs	r0, #2
    4412:	4479      	add	r1, pc
    4414:	f7ff fe98 	bl	4148 <main@@Base+0x1f4c>
    4418:	e00d      	b.n	4436 <main@@Base+0x223a>
    441a:	9a00      	ldr	r2, [sp, #0]
    441c:	b1ba      	cbz	r2, 444e <main@@Base+0x2252>
    441e:	f990 3000 	ldrsb.w	r3, [r0]
    4422:	2b00      	cmp	r3, #0
    4424:	da0a      	bge.n	443c <main@@Base+0x2240>
    4426:	4917      	ldr	r1, [pc, #92]	; (4484 <main@@Base+0x2288>)
    4428:	2002      	movs	r0, #2
    442a:	4479      	add	r1, pc
    442c:	f7ff fe8c 	bl	4148 <main@@Base+0x1f4c>
    4430:	4620      	mov	r0, r4
    4432:	f7fd ebfc 	blx	1c2c <free@plt+0x4>
    4436:	f04f 30ff 	mov.w	r0, #4294967295	; 0xffffffff
    443a:	e016      	b.n	446a <main@@Base+0x226e>
    443c:	f5b2 5f00 	cmp.w	r2, #8192	; 0x2000
    4440:	d905      	bls.n	444e <main@@Base+0x2252>
    4442:	4911      	ldr	r1, [pc, #68]	; (4488 <main@@Base+0x228c>)
    4444:	2002      	movs	r0, #2
    4446:	4479      	add	r1, pc
    4448:	f7ff fe7e 	bl	4148 <main@@Base+0x1f4c>
    444c:	e7f0      	b.n	4430 <main@@Base+0x2234>
    444e:	4611      	mov	r1, r2
    4450:	4620      	mov	r0, r4
    4452:	4632      	mov	r2, r6
    4454:	f7fd ec4a 	blx	1cec <BN_bin2bn@plt>
    4458:	b918      	cbnz	r0, 4462 <main@@Base+0x2266>
    445a:	490c      	ldr	r1, [pc, #48]	; (448c <main@@Base+0x2290>)
    445c:	2002      	movs	r0, #2
    445e:	4479      	add	r1, pc
    4460:	e7e4      	b.n	442c <main@@Base+0x2230>
    4462:	4620      	mov	r0, r4
    4464:	f7fd ebe2 	blx	1c2c <free@plt+0x4>
    4468:	2000      	movs	r0, #0
    446a:	9a01      	ldr	r2, [sp, #4]
    446c:	682b      	ldr	r3, [r5, #0]
    446e:	429a      	cmp	r2, r3
    4470:	d001      	beq.n	4476 <main@@Base+0x227a>
    4472:	f7fd ec74 	blx	1d5c <__stack_chk_fail@plt>
    4476:	bd7c      	pop	{r2, r3, r4, r5, r6, pc}
    4478:	4c04      	ldr	r4, [pc, #16]	; (448c <main@@Base+0x2290>)
    447a:	0000      	movs	r0, r0
    447c:	0258      	lsls	r0, r3, #9
    447e:	0000      	movs	r0, r0
    4480:	23e0      	movs	r3, #224	; 0xe0
    4482:	0000      	movs	r0, r0
    4484:	23ef      	movs	r3, #239	; 0xef
    4486:	0000      	movs	r0, r0
    4488:	240a      	movs	r4, #10
    448a:	0000      	movs	r0, r0
    448c:	2426      	movs	r4, #38	; 0x26
    448e:	0000      	movs	r0, r0
    4490:	4bd4      	ldr	r3, [pc, #848]	; (47e4 <main@@Base+0x25e8>)
    4492:	4ad5      	ldr	r2, [pc, #852]	; (47e8 <main@@Base+0x25ec>)
    4494:	447b      	add	r3, pc
    4496:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
    449a:	b089      	sub	sp, #36	; 0x24
    449c:	589b      	ldr	r3, [r3, r2]
    449e:	4605      	mov	r5, r0
    44a0:	6806      	ldr	r6, [r0, #0]
    44a2:	468b      	mov	fp, r1
    44a4:	680f      	ldr	r7, [r1, #0]
    44a6:	681a      	ldr	r2, [r3, #0]
    44a8:	9300      	str	r3, [sp, #0]
    44aa:	9207      	str	r2, [sp, #28]
    44ac:	2e00      	cmp	r6, #0
    44ae:	f040 8181 	bne.w	47b4 <main@@Base+0x25b8>
    44b2:	4638      	mov	r0, r7
    44b4:	2120      	movs	r1, #32
    44b6:	f7fd eb8e 	blx	1bd4 <strchr@plt>
    44ba:	4604      	mov	r4, r0
    44bc:	b918      	cbnz	r0, 44c6 <main@@Base+0x22ca>
    44be:	49cb      	ldr	r1, [pc, #812]	; (47ec <main@@Base+0x25f0>)
    44c0:	2002      	movs	r0, #2
    44c2:	4479      	add	r1, pc
    44c4:	e00b      	b.n	44de <main@@Base+0x22e2>
    44c6:	49ca      	ldr	r1, [pc, #808]	; (47f0 <main@@Base+0x25f4>)
    44c8:	7006      	strb	r6, [r0, #0]
    44ca:	4638      	mov	r0, r7
    44cc:	4479      	add	r1, pc
    44ce:	f7fd ee8a 	blx	21e4 <strcmp@plt>
    44d2:	2320      	movs	r3, #32
    44d4:	7023      	strb	r3, [r4, #0]
    44d6:	b128      	cbz	r0, 44e4 <main@@Base+0x22e8>
    44d8:	49c6      	ldr	r1, [pc, #792]	; (47f4 <main@@Base+0x25f8>)
    44da:	2002      	movs	r0, #2
    44dc:	4479      	add	r1, pc
    44de:	f7ff fe33 	bl	4148 <main@@Base+0x1f4c>
    44e2:	e16d      	b.n	47c0 <main@@Base+0x25c4>
    44e4:	f994 3001 	ldrsb.w	r3, [r4, #1]
    44e8:	b91b      	cbnz	r3, 44f2 <main@@Base+0x22f6>
    44ea:	49c3      	ldr	r1, [pc, #780]	; (47f8 <main@@Base+0x25fc>)
    44ec:	2002      	movs	r0, #2
    44ee:	4479      	add	r1, pc
    44f0:	e7f5      	b.n	44de <main@@Base+0x22e2>
    44f2:	682b      	ldr	r3, [r5, #0]
    44f4:	2b01      	cmp	r3, #1
    44f6:	bf08      	it	eq
    44f8:	6028      	streq	r0, [r5, #0]
    44fa:	d004      	beq.n	4506 <main@@Base+0x230a>
    44fc:	b11b      	cbz	r3, 4506 <main@@Base+0x230a>
    44fe:	49bf      	ldr	r1, [pc, #764]	; (47fc <main@@Base+0x2600>)
    4500:	2002      	movs	r0, #2
    4502:	4479      	add	r1, pc
    4504:	e7eb      	b.n	44de <main@@Base+0x22e2>
    4506:	1c67      	adds	r7, r4, #1
    4508:	4638      	mov	r0, r7
    450a:	f7fd ee1e 	blx	2148 <strlen@plt>
    450e:	0046      	lsls	r6, r0, #1
    4510:	4630      	mov	r0, r6
    4512:	f7fd ee62 	blx	21d8 <malloc@plt>
    4516:	4680      	mov	r8, r0
    4518:	4638      	mov	r0, r7
    451a:	f7fd ed84 	blx	2024 <strdup@plt>
    451e:	4681      	mov	r9, r0
    4520:	4602      	mov	r2, r0
    4522:	4613      	mov	r3, r2
    4524:	f912 1b01 	ldrsb.w	r1, [r2], #1
    4528:	f1a1 0e20 	sub.w	lr, r1, #32
    452c:	f1de 0000 	rsbs	r0, lr, #0
    4530:	eb40 000e 	adc.w	r0, r0, lr
    4534:	2909      	cmp	r1, #9
    4536:	bf14      	ite	ne
    4538:	4601      	movne	r1, r0
    453a:	f040 0101 	orreq.w	r1, r0, #1
    453e:	2900      	cmp	r1, #0
    4540:	d1ef      	bne.n	4522 <main@@Base+0x2326>
    4542:	4619      	mov	r1, r3
    4544:	f913 2b01 	ldrsb.w	r2, [r3], #1
    4548:	1c10      	adds	r0, r2, #0
    454a:	bf18      	it	ne
    454c:	2001      	movne	r0, #1
    454e:	2a20      	cmp	r2, #32
    4550:	bf0c      	ite	eq
    4552:	2000      	moveq	r0, #0
    4554:	f000 0001 	andne.w	r0, r0, #1
    4558:	b108      	cbz	r0, 455e <main@@Base+0x2362>
    455a:	2a09      	cmp	r2, #9
    455c:	d1f1      	bne.n	4542 <main@@Base+0x2346>
    455e:	4632      	mov	r2, r6
    4560:	f04f 0a00 	mov.w	sl, #0
    4564:	4648      	mov	r0, r9
    4566:	f881 a000 	strb.w	sl, [r1]
    456a:	4641      	mov	r1, r8
    456c:	f7fd eb2c 	blx	1bc8 <__b64_pton@plt>
    4570:	4606      	mov	r6, r0
    4572:	4648      	mov	r0, r9
    4574:	f7fd eb5a 	blx	1c2c <free@plt+0x4>
    4578:	4556      	cmp	r6, sl
    457a:	da09      	bge.n	4590 <main@@Base+0x2394>
    457c:	49a0      	ldr	r1, [pc, #640]	; (4800 <main@@Base+0x2604>)
    457e:	2002      	movs	r0, #2
    4580:	463a      	mov	r2, r7
    4582:	4479      	add	r1, pc
    4584:	f7ff fde0 	bl	4148 <main@@Base+0x1f4c>
    4588:	4640      	mov	r0, r8
    458a:	f7fd eb50 	blx	1c2c <free@plt+0x4>
    458e:	e117      	b.n	47c0 <main@@Base+0x25c4>
    4590:	f44f 5080 	mov.w	r0, #4096	; 0x1000
    4594:	f7fd ee20 	blx	21d8 <malloc@plt>
    4598:	f5b6 1f80 	cmp.w	r6, #1048576	; 0x100000
    459c:	f44f 5380 	mov.w	r3, #4096	; 0x1000
    45a0:	f8cd a014 	str.w	sl, [sp, #20]
    45a4:	9304      	str	r3, [sp, #16]
    45a6:	f8cd a018 	str.w	sl, [sp, #24]
    45aa:	9003      	str	r0, [sp, #12]
    45ac:	d905      	bls.n	45ba <main@@Base+0x23be>
    45ae:	4995      	ldr	r1, [pc, #596]	; (4804 <main@@Base+0x2608>)
    45b0:	2002      	movs	r0, #2
    45b2:	4632      	mov	r2, r6
    45b4:	4479      	add	r1, pc
    45b6:	f7ff fdc7 	bl	4148 <main@@Base+0x1f4c>
    45ba:	9b06      	ldr	r3, [sp, #24]
    45bc:	9a05      	ldr	r2, [sp, #20]
    45be:	429a      	cmp	r2, r3
    45c0:	d102      	bne.n	45c8 <main@@Base+0x23cc>
    45c2:	2300      	movs	r3, #0
    45c4:	9305      	str	r3, [sp, #20]
    45c6:	9306      	str	r3, [sp, #24]
    45c8:	f506 4afe 	add.w	sl, r6, #32512	; 0x7f00
    45cc:	4b8e      	ldr	r3, [pc, #568]	; (4808 <main@@Base+0x260c>)
    45ce:	f10a 0aff 	add.w	sl, sl, #255	; 0xff
    45d2:	447b      	add	r3, pc
    45d4:	9301      	str	r3, [sp, #4]
    45d6:	9b06      	ldr	r3, [sp, #24]
    45d8:	9904      	ldr	r1, [sp, #16]
    45da:	18f2      	adds	r2, r6, r3
    45dc:	428a      	cmp	r2, r1
    45de:	d20e      	bcs.n	45fe <main@@Base+0x2402>
    45e0:	9803      	ldr	r0, [sp, #12]
    45e2:	4641      	mov	r1, r8
    45e4:	9206      	str	r2, [sp, #24]
    45e6:	4632      	mov	r2, r6
    45e8:	18c0      	adds	r0, r0, r3
    45ea:	f7fd eb8e 	blx	1d08 <memcpy@plt+0x4>
    45ee:	a803      	add	r0, sp, #12
    45f0:	2100      	movs	r1, #0
    45f2:	f7ff fea1 	bl	4338 <main@@Base+0x213c>
    45f6:	4681      	mov	r9, r0
    45f8:	2800      	cmp	r0, #0
    45fa:	d132      	bne.n	4662 <main@@Base+0x2466>
    45fc:	e02a      	b.n	4654 <main@@Base+0x2458>
    45fe:	9a05      	ldr	r2, [sp, #20]
    4600:	f5b1 1f80 	cmp.w	r1, #1048576	; 0x100000
    4604:	bf34      	ite	cc
    4606:	4608      	movcc	r0, r1
    4608:	f44f 1080 	movcs.w	r0, #1048576	; 0x100000
    460c:	4282      	cmp	r2, r0
    460e:	d90b      	bls.n	4628 <main@@Base+0x242c>
    4610:	9803      	ldr	r0, [sp, #12]
    4612:	1881      	adds	r1, r0, r2
    4614:	1a9a      	subs	r2, r3, r2
    4616:	f7fd eaa0 	blx	1b58 <memmove@plt>
    461a:	9b05      	ldr	r3, [sp, #20]
    461c:	9a06      	ldr	r2, [sp, #24]
    461e:	1ad3      	subs	r3, r2, r3
    4620:	9306      	str	r3, [sp, #24]
    4622:	2300      	movs	r3, #0
    4624:	9305      	str	r3, [sp, #20]
    4626:	e7d6      	b.n	45d6 <main@@Base+0x23da>
    4628:	eb0a 0901 	add.w	r9, sl, r1
    462c:	f429 49fe 	bic.w	r9, r9, #32512	; 0x7f00
    4630:	f029 09ff 	bic.w	r9, r9, #255	; 0xff
    4634:	f5b9 0f20 	cmp.w	r9, #10485760	; 0xa00000
    4638:	d904      	bls.n	4644 <main@@Base+0x2448>
    463a:	2002      	movs	r0, #2
    463c:	9901      	ldr	r1, [sp, #4]
    463e:	464a      	mov	r2, r9
    4640:	f7ff fd82 	bl	4148 <main@@Base+0x1f4c>
    4644:	9803      	ldr	r0, [sp, #12]
    4646:	4649      	mov	r1, r9
    4648:	f7fd ea80 	blx	1b4c <realloc@plt>
    464c:	f8cd 9010 	str.w	r9, [sp, #16]
    4650:	9003      	str	r0, [sp, #12]
    4652:	e7c0      	b.n	45d6 <main@@Base+0x23da>
    4654:	496d      	ldr	r1, [pc, #436]	; (480c <main@@Base+0x2610>)
    4656:	2002      	movs	r0, #2
    4658:	464e      	mov	r6, r9
    465a:	4479      	add	r1, pc
    465c:	f7ff fd74 	bl	4148 <main@@Base+0x1f4c>
    4660:	e059      	b.n	4716 <main@@Base+0x251a>
    4662:	496b      	ldr	r1, [pc, #428]	; (4810 <main@@Base+0x2614>)
    4664:	4479      	add	r1, pc
    4666:	f7fd edbe 	blx	21e4 <strcmp@plt>
    466a:	f110 0a00 	adds.w	sl, r0, #0
    466e:	bf18      	it	ne
    4670:	f04f 0a01 	movne.w	sl, #1
    4674:	f1ba 0f00 	cmp.w	sl, #0
    4678:	d13b      	bne.n	46f2 <main@@Base+0x24f6>
    467a:	2108      	movs	r1, #8
    467c:	2001      	movs	r0, #1
    467e:	f7fd eab6 	blx	1bec <calloc@plt>
    4682:	f8c0 a000 	str.w	sl, [r0]
    4686:	4606      	mov	r6, r0
    4688:	f8c0 a004 	str.w	sl, [r0, #4]
    468c:	f7fd ec52 	blx	1f34 <RSA_new@plt>
    4690:	4682      	mov	sl, r0
    4692:	b920      	cbnz	r0, 469e <main@@Base+0x24a2>
    4694:	495f      	ldr	r1, [pc, #380]	; (4814 <main@@Base+0x2618>)
    4696:	2002      	movs	r0, #2
    4698:	4479      	add	r1, pc
    469a:	f7ff fd55 	bl	4148 <main@@Base+0x1f4c>
    469e:	f7fd eacc 	blx	1c38 <BN_new@plt>
    46a2:	f8ca 0010 	str.w	r0, [sl, #16]
    46a6:	b920      	cbnz	r0, 46b2 <main@@Base+0x24b6>
    46a8:	495b      	ldr	r1, [pc, #364]	; (4818 <main@@Base+0x261c>)
    46aa:	2002      	movs	r0, #2
    46ac:	4479      	add	r1, pc
    46ae:	f7ff fd4b 	bl	4148 <main@@Base+0x1f4c>
    46b2:	f7fd eac2 	blx	1c38 <BN_new@plt>
    46b6:	f8ca 0014 	str.w	r0, [sl, #20]
    46ba:	b920      	cbnz	r0, 46c6 <main@@Base+0x24ca>
    46bc:	4957      	ldr	r1, [pc, #348]	; (481c <main@@Base+0x2620>)
    46be:	2002      	movs	r0, #2
    46c0:	4479      	add	r1, pc
    46c2:	f7ff fd41 	bl	4148 <main@@Base+0x1f4c>
    46c6:	f8c6 a004 	str.w	sl, [r6, #4]
    46ca:	a803      	add	r0, sp, #12
    46cc:	f8da 1014 	ldr.w	r1, [sl, #20]
    46d0:	f7ff fe90 	bl	43f4 <main@@Base+0x21f8>
    46d4:	3001      	adds	r0, #1
    46d6:	d006      	beq.n	46e6 <main@@Base+0x24ea>
    46d8:	6873      	ldr	r3, [r6, #4]
    46da:	a803      	add	r0, sp, #12
    46dc:	6919      	ldr	r1, [r3, #16]
    46de:	f7ff fe89 	bl	43f4 <main@@Base+0x21f8>
    46e2:	3001      	adds	r0, #1
    46e4:	d10d      	bne.n	4702 <main@@Base+0x2506>
    46e6:	494e      	ldr	r1, [pc, #312]	; (4820 <main@@Base+0x2624>)
    46e8:	2002      	movs	r0, #2
    46ea:	4479      	add	r1, pc
    46ec:	f7ff fd2c 	bl	4148 <main@@Base+0x1f4c>
    46f0:	e007      	b.n	4702 <main@@Base+0x2506>
    46f2:	494c      	ldr	r1, [pc, #304]	; (4824 <main@@Base+0x2628>)
    46f4:	2002      	movs	r0, #2
    46f6:	464a      	mov	r2, r9
    46f8:	2600      	movs	r6, #0
    46fa:	4479      	add	r1, pc
    46fc:	f7ff fd24 	bl	4148 <main@@Base+0x1f4c>
    4700:	e066      	b.n	47d0 <main@@Base+0x25d4>
    4702:	9a06      	ldr	r2, [sp, #24]
    4704:	9b05      	ldr	r3, [sp, #20]
    4706:	1ad2      	subs	r2, r2, r3
    4708:	d062      	beq.n	47d0 <main@@Base+0x25d4>
    470a:	4947      	ldr	r1, [pc, #284]	; (4828 <main@@Base+0x262c>)
    470c:	2002      	movs	r0, #2
    470e:	4479      	add	r1, pc
    4710:	f7ff fd1a 	bl	4148 <main@@Base+0x1f4c>
    4714:	e05c      	b.n	47d0 <main@@Base+0x25d4>
    4716:	9a04      	ldr	r2, [sp, #16]
    4718:	b142      	cbz	r2, 472c <main@@Base+0x2530>
    471a:	9803      	ldr	r0, [sp, #12]
    471c:	2100      	movs	r1, #0
    471e:	f7fd eb5c 	blx	1dd8 <memset@plt+0x4>
    4722:	9803      	ldr	r0, [sp, #12]
    4724:	2300      	movs	r3, #0
    4726:	9304      	str	r3, [sp, #16]
    4728:	f7fd ea80 	blx	1c2c <free@plt+0x4>
    472c:	4640      	mov	r0, r8
    472e:	f7fd ea7e 	blx	1c2c <free@plt+0x4>
    4732:	b926      	cbnz	r6, 473e <main@@Base+0x2542>
    4734:	493d      	ldr	r1, [pc, #244]	; (482c <main@@Base+0x2630>)
    4736:	2002      	movs	r0, #2
    4738:	463a      	mov	r2, r7
    473a:	4479      	add	r1, pc
    473c:	e03e      	b.n	47bc <main@@Base+0x25c0>
    473e:	6833      	ldr	r3, [r6, #0]
    4740:	b143      	cbz	r3, 4754 <main@@Base+0x2558>
    4742:	493b      	ldr	r1, [pc, #236]	; (4830 <main@@Base+0x2634>)
    4744:	2002      	movs	r0, #2
    4746:	4479      	add	r1, pc
    4748:	f7ff fcfe 	bl	4148 <main@@Base+0x1f4c>
    474c:	4630      	mov	r0, r6
    474e:	f7ff fdb5 	bl	42bc <main@@Base+0x20c0>
    4752:	e035      	b.n	47c0 <main@@Base+0x25c4>
    4754:	682b      	ldr	r3, [r5, #0]
    4756:	b93b      	cbnz	r3, 4768 <main@@Base+0x256c>
    4758:	6868      	ldr	r0, [r5, #4]
    475a:	b108      	cbz	r0, 4760 <main@@Base+0x2564>
    475c:	f7fd eacc 	blx	1cf8 <RSA_free@plt>
    4760:	6873      	ldr	r3, [r6, #4]
    4762:	606b      	str	r3, [r5, #4]
    4764:	2300      	movs	r3, #0
    4766:	6073      	str	r3, [r6, #4]
    4768:	4630      	mov	r0, r6
    476a:	f7ff fda7 	bl	42bc <main@@Base+0x20c0>
    476e:	e000      	b.n	4772 <main@@Base+0x2576>
    4770:	461c      	mov	r4, r3
    4772:	f994 2001 	ldrsb.w	r2, [r4, #1]
    4776:	1c63      	adds	r3, r4, #1
    4778:	f1a2 0020 	sub.w	r0, r2, #32
    477c:	4241      	negs	r1, r0
    477e:	eb41 0100 	adc.w	r1, r1, r0
    4782:	2a09      	cmp	r2, #9
    4784:	bf14      	ite	ne
    4786:	460a      	movne	r2, r1
    4788:	f041 0201 	orreq.w	r2, r1, #1
    478c:	2a00      	cmp	r2, #0
    478e:	d1ef      	bne.n	4770 <main@@Base+0x2574>
    4790:	4619      	mov	r1, r3
    4792:	f913 2b01 	ldrsb.w	r2, [r3], #1
    4796:	1c10      	adds	r0, r2, #0
    4798:	bf18      	it	ne
    479a:	2001      	movne	r0, #1
    479c:	2a20      	cmp	r2, #32
    479e:	bf0c      	ite	eq
    47a0:	2000      	moveq	r0, #0
    47a2:	f000 0001 	andne.w	r0, r0, #1
    47a6:	b108      	cbz	r0, 47ac <main@@Base+0x25b0>
    47a8:	2a09      	cmp	r2, #9
    47aa:	d1f1      	bne.n	4790 <main@@Base+0x2594>
    47ac:	f8cb 1000 	str.w	r1, [fp]
    47b0:	2001      	movs	r0, #1
    47b2:	e007      	b.n	47c4 <main@@Base+0x25c8>
    47b4:	491f      	ldr	r1, [pc, #124]	; (4834 <main@@Base+0x2638>)
    47b6:	2002      	movs	r0, #2
    47b8:	4632      	mov	r2, r6
    47ba:	4479      	add	r1, pc
    47bc:	f7ff fcc4 	bl	4148 <main@@Base+0x1f4c>
    47c0:	f04f 30ff 	mov.w	r0, #4294967295	; 0xffffffff
    47c4:	9900      	ldr	r1, [sp, #0]
    47c6:	9a07      	ldr	r2, [sp, #28]
    47c8:	680b      	ldr	r3, [r1, #0]
    47ca:	429a      	cmp	r2, r3
    47cc:	d006      	beq.n	47dc <main@@Base+0x25e0>
    47ce:	e003      	b.n	47d8 <main@@Base+0x25dc>
    47d0:	4648      	mov	r0, r9
    47d2:	f7fd ea2c 	blx	1c2c <free@plt+0x4>
    47d6:	e79e      	b.n	4716 <main@@Base+0x251a>
    47d8:	f7fd eac0 	blx	1d5c <__stack_chk_fail@plt>
    47dc:	b009      	add	sp, #36	; 0x24
    47de:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
    47e2:	bf00      	nop
    47e4:	4b68      	ldr	r3, [pc, #416]	; (4988 <main@@Base+0x278c>)
    47e6:	0000      	movs	r0, r0
    47e8:	0258      	lsls	r0, r3, #9
    47ea:	0000      	movs	r0, r0
    47ec:	23eb      	movs	r3, #235	; 0xeb
    47ee:	0000      	movs	r0, r0
    47f0:	23fe      	movs	r3, #254	; 0xfe
    47f2:	0000      	movs	r0, r0
    47f4:	23f6      	movs	r3, #246	; 0xf6
    47f6:	0000      	movs	r0, r0
    47f8:	23fe      	movs	r3, #254	; 0xfe
    47fa:	0000      	movs	r0, r0
    47fc:	2401      	movs	r4, #1
    47fe:	0000      	movs	r0, r0
    4800:	2399      	movs	r3, #153	; 0x99
    4802:	0000      	movs	r0, r0
    4804:	2384      	movs	r3, #132	; 0x84
    4806:	0000      	movs	r0, r0
    4808:	2390      	movs	r3, #144	; 0x90
    480a:	0000      	movs	r0, r0
    480c:	2334      	movs	r3, #52	; 0x34
    480e:	0000      	movs	r0, r0
    4810:	2266      	movs	r2, #102	; 0x66
    4812:	0000      	movs	r0, r0
    4814:	2319      	movs	r3, #25
    4816:	0000      	movs	r0, r0
    4818:	231d      	movs	r3, #29
    481a:	0000      	movs	r0, r0
    481c:	2309      	movs	r3, #9
    481e:	0000      	movs	r0, r0
    4820:	22f6      	movs	r2, #246	; 0xf6
    4822:	0000      	movs	r0, r0
    4824:	2308      	movs	r3, #8
    4826:	0000      	movs	r0, r0
    4828:	2319      	movs	r3, #25
    482a:	0000      	movs	r0, r0
    482c:	231b      	movs	r3, #27
    482e:	0000      	movs	r0, r0
    4830:	2331      	movs	r3, #49	; 0x31
    4832:	0000      	movs	r0, r0
    4834:	22e5      	movs	r2, #229	; 0xe5
    4836:	0000      	movs	r0, r0
    4838:	4b64      	ldr	r3, [pc, #400]	; (49cc <main@@Base+0x27d0>)
    483a:	2102      	movs	r1, #2
    483c:	4a64      	ldr	r2, [pc, #400]	; (49d0 <main@@Base+0x27d4>)
    483e:	447b      	add	r3, pc
    4840:	4864      	ldr	r0, [pc, #400]	; (49d4 <main@@Base+0x27d8>)
    4842:	e92d 41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
    4846:	f5ad 6dc1 	sub.w	sp, sp, #1544	; 0x608
    484a:	589f      	ldr	r7, [r3, r2]
    484c:	4478      	add	r0, pc
    484e:	683b      	ldr	r3, [r7, #0]
    4850:	f8cd 3604 	str.w	r3, [sp, #1540]	; 0x604
    4854:	f7fd ec40 	blx	20d8 <open@plt>
    4858:	1c43      	adds	r3, r0, #1
    485a:	4605      	mov	r5, r0
    485c:	d108      	bne.n	4870 <main@@Base+0x2674>
    485e:	495e      	ldr	r1, [pc, #376]	; (49d8 <main@@Base+0x27dc>)
    4860:	2002      	movs	r0, #2
    4862:	4a5e      	ldr	r2, [pc, #376]	; (49dc <main@@Base+0x27e0>)
    4864:	462c      	mov	r4, r5
    4866:	4479      	add	r1, pc
    4868:	447a      	add	r2, pc
    486a:	f7ff fc6d 	bl	4148 <main@@Base+0x1f4c>
    486e:	e09f      	b.n	49b0 <main@@Base+0x27b4>
    4870:	a801      	add	r0, sp, #4
    4872:	2100      	movs	r1, #0
    4874:	4e5a      	ldr	r6, [pc, #360]	; (49e0 <main@@Base+0x27e4>)
    4876:	f7fd eca4 	blx	21c0 <pps_encoder_initialize@plt>
    487a:	4c5a      	ldr	r4, [pc, #360]	; (49e4 <main@@Base+0x27e8>)
    487c:	a801      	add	r0, sp, #4
    487e:	495a      	ldr	r1, [pc, #360]	; (49e8 <main@@Base+0x27ec>)
    4880:	447e      	add	r6, pc
    4882:	4a5a      	ldr	r2, [pc, #360]	; (49ec <main@@Base+0x27f0>)
    4884:	447c      	add	r4, pc
    4886:	4479      	add	r1, pc
    4888:	447a      	add	r2, pc
    488a:	f7fd eb66 	blx	1f58 <pps_encoder_add_string@plt>
    488e:	a801      	add	r0, sp, #4
    4890:	4631      	mov	r1, r6
    4892:	4622      	mov	r2, r4
    4894:	f7fd eb60 	blx	1f58 <pps_encoder_add_string@plt>
    4898:	a801      	add	r0, sp, #4
    489a:	f7fd eae6 	blx	1e68 <pps_encoder_buffer@plt>
    489e:	2800      	cmp	r0, #0
    48a0:	d035      	beq.n	490e <main@@Base+0x2712>
    48a2:	a801      	add	r0, sp, #4
    48a4:	f7fd eb88 	blx	1fb8 <pps_encoder_length@plt>
    48a8:	4680      	mov	r8, r0
    48aa:	a801      	add	r0, sp, #4
    48ac:	f7fd eadc 	blx	1e68 <pps_encoder_buffer@plt>
    48b0:	4642      	mov	r2, r8
    48b2:	4601      	mov	r1, r0
    48b4:	4628      	mov	r0, r5
    48b6:	f7fd eb74 	blx	1fa0 <write@plt>
    48ba:	4540      	cmp	r0, r8
    48bc:	d007      	beq.n	48ce <main@@Base+0x26d2>
    48be:	a801      	add	r0, sp, #4
    48c0:	f7fd ead2 	blx	1e68 <pps_encoder_buffer@plt>
    48c4:	494a      	ldr	r1, [pc, #296]	; (49f0 <main@@Base+0x27f4>)
    48c6:	4479      	add	r1, pc
    48c8:	4602      	mov	r2, r0
    48ca:	2002      	movs	r0, #2
    48cc:	e04a      	b.n	4964 <main@@Base+0x2768>
    48ce:	f50d 6180 	add.w	r1, sp, #1024	; 0x400
    48d2:	f240 12ff 	movw	r2, #511	; 0x1ff
    48d6:	3104      	adds	r1, #4
    48d8:	4628      	mov	r0, r5
    48da:	f7fd eaba 	blx	1e50 <read@plt>
    48de:	2100      	movs	r1, #0
    48e0:	460a      	mov	r2, r1
    48e2:	4680      	mov	r8, r0
    48e4:	a80c      	add	r0, sp, #48	; 0x30
    48e6:	f7fd e9c6 	blx	1c74 <pps_decoder_init@plt>
    48ea:	f50d 6180 	add.w	r1, sp, #1024	; 0x400
    48ee:	4642      	mov	r2, r8
    48f0:	3104      	adds	r1, #4
    48f2:	a80c      	add	r0, sp, #48	; 0x30
    48f4:	f7fd ea38 	blx	1d68 <pps_decoder_parse@plt>
    48f8:	2100      	movs	r1, #0
    48fa:	a80c      	add	r0, sp, #48	; 0x30
    48fc:	f7fd ea0a 	blx	1d14 <pps_decoder_push@plt>
    4900:	a80c      	add	r0, sp, #48	; 0x30
    4902:	4631      	mov	r1, r6
    4904:	aa08      	add	r2, sp, #32
    4906:	f7fd ebee 	blx	20e4 <pps_decoder_get_string@plt>
    490a:	b140      	cbz	r0, 491e <main@@Base+0x2722>
    490c:	e00d      	b.n	492a <main@@Base+0x272e>
    490e:	4939      	ldr	r1, [pc, #228]	; (49f4 <main@@Base+0x27f8>)
    4910:	2002      	movs	r0, #2
    4912:	4479      	add	r1, pc
    4914:	f7ff fc18 	bl	4148 <main@@Base+0x1f4c>
    4918:	f04f 34ff 	mov.w	r4, #4294967295	; 0xffffffff
    491c:	e039      	b.n	4992 <main@@Base+0x2796>
    491e:	9808      	ldr	r0, [sp, #32]
    4920:	b118      	cbz	r0, 492a <main@@Base+0x272e>
    4922:	4621      	mov	r1, r4
    4924:	f7fd ec5e 	blx	21e4 <strcmp@plt>
    4928:	b118      	cbz	r0, 4932 <main@@Base+0x2736>
    492a:	4933      	ldr	r1, [pc, #204]	; (49f8 <main@@Base+0x27fc>)
    492c:	2002      	movs	r0, #2
    492e:	4479      	add	r1, pc
    4930:	e7f0      	b.n	4914 <main@@Base+0x2718>
    4932:	4932      	ldr	r1, [pc, #200]	; (49fc <main@@Base+0x2800>)
    4934:	a80c      	add	r0, sp, #48	; 0x30
    4936:	aa09      	add	r2, sp, #36	; 0x24
    4938:	4479      	add	r1, pc
    493a:	f7fd e926 	blx	1b88 <pps_decoder_get_int@plt>
    493e:	2803      	cmp	r0, #3
    4940:	a80c      	add	r0, sp, #48	; 0x30
    4942:	d11c      	bne.n	497e <main@@Base+0x2782>
    4944:	4c2e      	ldr	r4, [pc, #184]	; (4a00 <main@@Base+0x2804>)
    4946:	492f      	ldr	r1, [pc, #188]	; (4a04 <main@@Base+0x2808>)
    4948:	447c      	add	r4, pc
    494a:	4479      	add	r1, pc
    494c:	f7fd e9e2 	blx	1d14 <pps_decoder_push@plt>
    4950:	a80c      	add	r0, sp, #48	; 0x30
    4952:	4621      	mov	r1, r4
    4954:	aa0b      	add	r2, sp, #44	; 0x2c
    4956:	f7fd e918 	blx	1b88 <pps_decoder_get_int@plt>
    495a:	b130      	cbz	r0, 496a <main@@Base+0x276e>
    495c:	492a      	ldr	r1, [pc, #168]	; (4a08 <main@@Base+0x280c>)
    495e:	2002      	movs	r0, #2
    4960:	4622      	mov	r2, r4
    4962:	4479      	add	r1, pc
    4964:	f7ff fbf0 	bl	4148 <main@@Base+0x1f4c>
    4968:	e7d6      	b.n	4918 <main@@Base+0x271c>
    496a:	9b0b      	ldr	r3, [sp, #44]	; 0x2c
    496c:	a80c      	add	r0, sp, #48	; 0x30
    496e:	2b00      	cmp	r3, #0
    4970:	bf0c      	ite	eq
    4972:	f06f 0409 	mvneq.w	r4, #9
    4976:	2400      	movne	r4, #0
    4978:	f7fd eb90 	blx	209c <pps_decoder_pop@plt>
    497c:	e006      	b.n	498c <main@@Base+0x2790>
    497e:	4923      	ldr	r1, [pc, #140]	; (4a0c <main@@Base+0x2810>)
    4980:	aa0a      	add	r2, sp, #40	; 0x28
    4982:	f04f 34ff 	mov.w	r4, #4294967295	; 0xffffffff
    4986:	4479      	add	r1, pc
    4988:	f7fd ebac 	blx	20e4 <pps_decoder_get_string@plt>
    498c:	a80c      	add	r0, sp, #48	; 0x30
    498e:	f7fd eb86 	blx	209c <pps_decoder_pop@plt>
    4992:	a801      	add	r0, sp, #4
    4994:	f7fd ea62 	blx	1e5c <pps_encoder_cleanup@plt>
    4998:	a80c      	add	r0, sp, #48	; 0x30
    499a:	f7fd eb98 	blx	20cc <pps_decoder_cleanup@plt>
    499e:	4628      	mov	r0, r5
    49a0:	f7fd e90c 	blx	1bbc <close@plt+0x4>
    49a4:	491a      	ldr	r1, [pc, #104]	; (4a10 <main@@Base+0x2814>)
    49a6:	2005      	movs	r0, #5
    49a8:	4622      	mov	r2, r4
    49aa:	4479      	add	r1, pc
    49ac:	f7ff fbcc 	bl	4148 <main@@Base+0x1f4c>
    49b0:	f8dd 2604 	ldr.w	r2, [sp, #1540]	; 0x604
    49b4:	4620      	mov	r0, r4
    49b6:	683b      	ldr	r3, [r7, #0]
    49b8:	429a      	cmp	r2, r3
    49ba:	d001      	beq.n	49c0 <main@@Base+0x27c4>
    49bc:	f7fd e9ce 	blx	1d5c <__stack_chk_fail@plt>
    49c0:	f50d 7d02 	add.w	sp, sp, #520	; 0x208
    49c4:	f50d 6d80 	add.w	sp, sp, #1024	; 0x400
    49c8:	e8bd 81f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, pc}
    49cc:	47be      			; <UNDEFINED> instruction: 0x47be
    49ce:	0000      	movs	r0, r0
    49d0:	0258      	lsls	r0, r3, #9
    49d2:	0000      	movs	r0, r0
    49d4:	226e      	movs	r2, #110	; 0x6e
    49d6:	0000      	movs	r0, r0
    49d8:	2287      	movs	r2, #135	; 0x87
    49da:	0000      	movs	r0, r0
    49dc:	2296      	movs	r2, #150	; 0x96
    49de:	0000      	movs	r0, r0
    49e0:	2506      	movs	r5, #6
    49e2:	0000      	movs	r0, r0
    49e4:	22b3      	movs	r2, #179	; 0xb3
    49e6:	0000      	movs	r0, r0
    49e8:	22a6      	movs	r2, #166	; 0xa6
    49ea:	0000      	movs	r0, r0
    49ec:	22a8      	movs	r2, #168	; 0xa8
    49ee:	0000      	movs	r0, r0
    49f0:	2274      	movs	r2, #116	; 0x74
    49f2:	0000      	movs	r0, r0
    49f4:	2242      	movs	r2, #66	; 0x42
    49f6:	0000      	movs	r0, r0
    49f8:	223a      	movs	r2, #58	; 0x3a
    49fa:	0000      	movs	r0, r0
    49fc:	224e      	movs	r2, #78	; 0x4e
    49fe:	0000      	movs	r0, r0
    4a00:	2246      	movs	r2, #70	; 0x46
    4a02:	0000      	movs	r0, r0
    4a04:	2240      	movs	r2, #64	; 0x40
    4a06:	0000      	movs	r0, r0
    4a08:	223b      	movs	r2, #59	; 0x3b
    4a0a:	0000      	movs	r0, r0
    4a0c:	223b      	movs	r2, #59	; 0x3b
    4a0e:	0000      	movs	r0, r0
    4a10:	221e      	movs	r2, #30
    4a12:	0000      	movs	r0, r0
    4a14:	f110 0f0a 	cmn.w	r0, #10
    4a18:	d002      	beq.n	4a20 <main@@Base+0x2824>
    4a1a:	2822      	cmp	r0, #34	; 0x22
    4a1c:	d103      	bne.n	4a26 <main@@Base+0x282a>
    4a1e:	e005      	b.n	4a2c <main@@Base+0x2830>
    4a20:	4804      	ldr	r0, [pc, #16]	; (4a34 <main@@Base+0x2838>)
    4a22:	4478      	add	r0, pc
    4a24:	4770      	bx	lr
    4a26:	200b      	movs	r0, #11
    4a28:	f7ff bb86 	b.w	4138 <main@@Base+0x1f3c>
    4a2c:	4802      	ldr	r0, [pc, #8]	; (4a38 <main@@Base+0x283c>)
    4a2e:	4478      	add	r0, pc
    4a30:	4770      	bx	lr
    4a32:	bf00      	nop
    4a34:	21bb      	movs	r1, #187	; 0xbb
    4a36:	0000      	movs	r0, r0
    4a38:	21e5      	movs	r1, #229	; 0xe5
    4a3a:	0000      	movs	r0, r0
    4a3c:	4b6e      	ldr	r3, [pc, #440]	; (4bf8 <main@@Base+0x29fc>)
    4a3e:	4a6f      	ldr	r2, [pc, #444]	; (4bfc <main@@Base+0x2a00>)
    4a40:	447b      	add	r3, pc
    4a42:	b5f0      	push	{r4, r5, r6, r7, lr}
    4a44:	f5ad 6dc0 	sub.w	sp, sp, #1536	; 0x600
    4a48:	589f      	ldr	r7, [r3, r2]
    4a4a:	b083      	sub	sp, #12
    4a4c:	460c      	mov	r4, r1
    4a4e:	4605      	mov	r5, r0
    4a50:	683b      	ldr	r3, [r7, #0]
    4a52:	f8cd 3604 	str.w	r3, [sp, #1540]	; 0x604
    4a56:	f7ff feef 	bl	4838 <main@@Base+0x263c>
    4a5a:	4606      	mov	r6, r0
    4a5c:	6020      	str	r0, [r4, #0]
    4a5e:	2800      	cmp	r0, #0
    4a60:	f040 80bb 	bne.w	4bda <main@@Base+0x29de>
    4a64:	4866      	ldr	r0, [pc, #408]	; (4c00 <main@@Base+0x2a04>)
    4a66:	2102      	movs	r1, #2
    4a68:	4478      	add	r0, pc
    4a6a:	f7fd eb36 	blx	20d8 <open@plt>
    4a6e:	2800      	cmp	r0, #0
    4a70:	4604      	mov	r4, r0
    4a72:	dc05      	bgt.n	4a80 <main@@Base+0x2884>
    4a74:	4963      	ldr	r1, [pc, #396]	; (4c04 <main@@Base+0x2a08>)
    4a76:	2002      	movs	r0, #2
    4a78:	4479      	add	r1, pc
    4a7a:	f7ff fb65 	bl	4148 <main@@Base+0x1f4c>
    4a7e:	e0ac      	b.n	4bda <main@@Base+0x29de>
    4a80:	4668      	mov	r0, sp
    4a82:	4631      	mov	r1, r6
    4a84:	f7fd eb9c 	blx	21c0 <pps_encoder_initialize@plt>
    4a88:	495f      	ldr	r1, [pc, #380]	; (4c08 <main@@Base+0x2a0c>)
    4a8a:	4a60      	ldr	r2, [pc, #384]	; (4c0c <main@@Base+0x2a10>)
    4a8c:	4668      	mov	r0, sp
    4a8e:	4479      	add	r1, pc
    4a90:	447a      	add	r2, pc
    4a92:	f7fd ea62 	blx	1f58 <pps_encoder_add_string@plt>
    4a96:	495e      	ldr	r1, [pc, #376]	; (4c10 <main@@Base+0x2a14>)
    4a98:	4a5e      	ldr	r2, [pc, #376]	; (4c14 <main@@Base+0x2a18>)
    4a9a:	4668      	mov	r0, sp
    4a9c:	4479      	add	r1, pc
    4a9e:	447a      	add	r2, pc
    4aa0:	f7fd ea5a 	blx	1f58 <pps_encoder_add_string@plt>
    4aa4:	a8ff      	add	r0, sp, #1020	; 0x3fc
    4aa6:	4631      	mov	r1, r6
    4aa8:	f44f 7200 	mov.w	r2, #512	; 0x200
    4aac:	f7fd e994 	blx	1dd8 <memset@plt+0x4>
    4ab0:	4668      	mov	r0, sp
    4ab2:	f7fd e9da 	blx	1e68 <pps_encoder_buffer@plt>
    4ab6:	b1e8      	cbz	r0, 4af4 <main@@Base+0x28f8>
    4ab8:	4668      	mov	r0, sp
    4aba:	f7fd ea7e 	blx	1fb8 <pps_encoder_length@plt>
    4abe:	4606      	mov	r6, r0
    4ac0:	4668      	mov	r0, sp
    4ac2:	f7fd e9d2 	blx	1e68 <pps_encoder_buffer@plt>
    4ac6:	4632      	mov	r2, r6
    4ac8:	4601      	mov	r1, r0
    4aca:	4620      	mov	r0, r4
    4acc:	f7fd ea68 	blx	1fa0 <write@plt>
    4ad0:	42b0      	cmp	r0, r6
    4ad2:	d009      	beq.n	4ae8 <main@@Base+0x28ec>
    4ad4:	4668      	mov	r0, sp
    4ad6:	f7fd e9c8 	blx	1e68 <pps_encoder_buffer@plt>
    4ada:	494f      	ldr	r1, [pc, #316]	; (4c18 <main@@Base+0x2a1c>)
    4adc:	4479      	add	r1, pc
    4ade:	4602      	mov	r2, r0
    4ae0:	2002      	movs	r0, #2
    4ae2:	f7ff fb31 	bl	4148 <main@@Base+0x1f4c>
    4ae6:	e027      	b.n	4b38 <main@@Base+0x293c>
    4ae8:	4620      	mov	r0, r4
    4aea:	a9ff      	add	r1, sp, #1020	; 0x3fc
    4aec:	f240 12ff 	movw	r2, #511	; 0x1ff
    4af0:	f7fd e9ae 	blx	1e50 <read@plt>
    4af4:	2100      	movs	r1, #0
    4af6:	4606      	mov	r6, r0
    4af8:	a80a      	add	r0, sp, #40	; 0x28
    4afa:	460a      	mov	r2, r1
    4afc:	f7fd e8ba 	blx	1c74 <pps_decoder_init@plt>
    4b00:	4632      	mov	r2, r6
    4b02:	a9ff      	add	r1, sp, #1020	; 0x3fc
    4b04:	a80a      	add	r0, sp, #40	; 0x28
    4b06:	f7fd e930 	blx	1d68 <pps_decoder_parse@plt>
    4b0a:	2100      	movs	r1, #0
    4b0c:	a80a      	add	r0, sp, #40	; 0x28
    4b0e:	f7fd e902 	blx	1d14 <pps_decoder_push@plt>
    4b12:	4942      	ldr	r1, [pc, #264]	; (4c1c <main@@Base+0x2a20>)
    4b14:	a80a      	add	r0, sp, #40	; 0x28
    4b16:	aa07      	add	r2, sp, #28
    4b18:	4479      	add	r1, pc
    4b1a:	f7fd eae4 	blx	20e4 <pps_decoder_get_string@plt>
    4b1e:	b930      	cbnz	r0, 4b2e <main@@Base+0x2932>
    4b20:	9807      	ldr	r0, [sp, #28]
    4b22:	b120      	cbz	r0, 4b2e <main@@Base+0x2932>
    4b24:	493e      	ldr	r1, [pc, #248]	; (4c20 <main@@Base+0x2a24>)
    4b26:	4479      	add	r1, pc
    4b28:	f7fd eb5c 	blx	21e4 <strcmp@plt>
    4b2c:	b138      	cbz	r0, 4b3e <main@@Base+0x2942>
    4b2e:	493d      	ldr	r1, [pc, #244]	; (4c24 <main@@Base+0x2a28>)
    4b30:	2002      	movs	r0, #2
    4b32:	4479      	add	r1, pc
    4b34:	f7ff fb08 	bl	4148 <main@@Base+0x1f4c>
    4b38:	f04f 35ff 	mov.w	r5, #4294967295	; 0xffffffff
    4b3c:	e043      	b.n	4bc6 <main@@Base+0x29ca>
    4b3e:	493a      	ldr	r1, [pc, #232]	; (4c28 <main@@Base+0x2a2c>)
    4b40:	a80a      	add	r0, sp, #40	; 0x28
    4b42:	4479      	add	r1, pc
    4b44:	f7fd e8e6 	blx	1d14 <pps_decoder_push@plt>
    4b48:	4938      	ldr	r1, [pc, #224]	; (4c2c <main@@Base+0x2a30>)
    4b4a:	a80a      	add	r0, sp, #40	; 0x28
    4b4c:	462a      	mov	r2, r5
    4b4e:	4479      	add	r1, pc
    4b50:	f7fd e81a 	blx	1b88 <pps_decoder_get_int@plt>
    4b54:	b120      	cbz	r0, 4b60 <main@@Base+0x2964>
    4b56:	4936      	ldr	r1, [pc, #216]	; (4c30 <main@@Base+0x2a34>)
    4b58:	2002      	movs	r0, #2
    4b5a:	4479      	add	r1, pc
    4b5c:	f7ff faf4 	bl	4148 <main@@Base+0x1f4c>
    4b60:	682b      	ldr	r3, [r5, #0]
    4b62:	b34b      	cbz	r3, 4bb8 <main@@Base+0x29bc>
    4b64:	4933      	ldr	r1, [pc, #204]	; (4c34 <main@@Base+0x2a38>)
    4b66:	f105 0208 	add.w	r2, r5, #8
    4b6a:	a80a      	add	r0, sp, #40	; 0x28
    4b6c:	4479      	add	r1, pc
    4b6e:	f7fd e80c 	blx	1b88 <pps_decoder_get_int@plt>
    4b72:	b120      	cbz	r0, 4b7e <main@@Base+0x2982>
    4b74:	4930      	ldr	r1, [pc, #192]	; (4c38 <main@@Base+0x2a3c>)
    4b76:	2002      	movs	r0, #2
    4b78:	4479      	add	r1, pc
    4b7a:	f7ff fae5 	bl	4148 <main@@Base+0x1f4c>
    4b7e:	492f      	ldr	r1, [pc, #188]	; (4c3c <main@@Base+0x2a40>)
    4b80:	a80a      	add	r0, sp, #40	; 0x28
    4b82:	aa08      	add	r2, sp, #32
    4b84:	4479      	add	r1, pc
    4b86:	f7fd eaae 	blx	20e4 <pps_decoder_get_string@plt>
    4b8a:	b128      	cbz	r0, 4b98 <main@@Base+0x299c>
    4b8c:	492c      	ldr	r1, [pc, #176]	; (4c40 <main@@Base+0x2a44>)
    4b8e:	2002      	movs	r0, #2
    4b90:	4479      	add	r1, pc
    4b92:	f7ff fad9 	bl	4148 <main@@Base+0x1f4c>
    4b96:	e00f      	b.n	4bb8 <main@@Base+0x29bc>
    4b98:	f50d 61be 	add.w	r1, sp, #1520	; 0x5f0
    4b9c:	aa09      	add	r2, sp, #36	; 0x24
    4b9e:	9808      	ldr	r0, [sp, #32]
    4ba0:	310c      	adds	r1, #12
    4ba2:	2308      	movs	r3, #8
    4ba4:	9309      	str	r3, [sp, #36]	; 0x24
    4ba6:	f000 fab9 	bl	511c <main@@Base+0x2f20>
    4baa:	f50d 63be 	add.w	r3, sp, #1520	; 0x5f0
    4bae:	330c      	adds	r3, #12
    4bb0:	e9d3 2300 	ldrd	r2, r3, [r3]
    4bb4:	e9c5 2304 	strd	r2, r3, [r5, #16]
    4bb8:	a80a      	add	r0, sp, #40	; 0x28
    4bba:	2500      	movs	r5, #0
    4bbc:	f7fd ea6e 	blx	209c <pps_decoder_pop@plt>
    4bc0:	a80a      	add	r0, sp, #40	; 0x28
    4bc2:	f7fd ea6c 	blx	209c <pps_decoder_pop@plt>
    4bc6:	4668      	mov	r0, sp
    4bc8:	f7fd e948 	blx	1e5c <pps_encoder_cleanup@plt>
    4bcc:	a80a      	add	r0, sp, #40	; 0x28
    4bce:	f7fd ea7e 	blx	20cc <pps_decoder_cleanup@plt>
    4bd2:	4620      	mov	r0, r4
    4bd4:	f7fc eff2 	blx	1bbc <close@plt+0x4>
    4bd8:	e001      	b.n	4bde <main@@Base+0x29e2>
    4bda:	f04f 35ff 	mov.w	r5, #4294967295	; 0xffffffff
    4bde:	f8dd 2604 	ldr.w	r2, [sp, #1540]	; 0x604
    4be2:	4628      	mov	r0, r5
    4be4:	683b      	ldr	r3, [r7, #0]
    4be6:	429a      	cmp	r2, r3
    4be8:	d001      	beq.n	4bee <main@@Base+0x29f2>
    4bea:	f7fd e8b8 	blx	1d5c <__stack_chk_fail@plt>
    4bee:	f50d 7d03 	add.w	sp, sp, #524	; 0x20c
    4bf2:	f50d 6d80 	add.w	sp, sp, #1024	; 0x400
    4bf6:	bdf0      	pop	{r4, r5, r6, r7, pc}
    4bf8:	45bc      	cmp	ip, r7
    4bfa:	0000      	movs	r0, r0
    4bfc:	0258      	lsls	r0, r3, #9
    4bfe:	0000      	movs	r0, r0
    4c00:	2052      	movs	r0, #82	; 0x52
    4c02:	0000      	movs	r0, r0
    4c04:	21d7      	movs	r1, #215	; 0xd7
    4c06:	0000      	movs	r0, r0
    4c08:	209e      	movs	r0, #158	; 0x9e
    4c0a:	0000      	movs	r0, r0
    4c0c:	220f      	movs	r2, #15
    4c0e:	0000      	movs	r0, r0
    4c10:	22ea      	movs	r2, #234	; 0xea
    4c12:	0000      	movs	r0, r0
    4c14:	2099      	movs	r0, #153	; 0x99
    4c16:	0000      	movs	r0, r0
    4c18:	2190      	movs	r1, #144	; 0x90
    4c1a:	0000      	movs	r0, r0
    4c1c:	226e      	movs	r2, #110	; 0x6e
    4c1e:	0000      	movs	r0, r0
    4c20:	2011      	movs	r0, #17
    4c22:	0000      	movs	r0, r0
    4c24:	2155      	movs	r1, #85	; 0x55
    4c26:	0000      	movs	r0, r0
    4c28:	2048      	movs	r0, #72	; 0x48
    4c2a:	0000      	movs	r0, r0
    4c2c:	215a      	movs	r1, #90	; 0x5a
    4c2e:	0000      	movs	r0, r0
    4c30:	2158      	movs	r1, #88	; 0x58
    4c32:	0000      	movs	r0, r0
    4c34:	2160      	movs	r1, #96	; 0x60
    4c36:	0000      	movs	r0, r0
    4c38:	215b      	movs	r1, #91	; 0x5b
    4c3a:	0000      	movs	r0, r0
    4c3c:	2166      	movs	r1, #102	; 0x66
    4c3e:	0000      	movs	r0, r0
    4c40:	215f      	movs	r1, #95	; 0x5f
    4c42:	0000      	movs	r0, r0
    4c44:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
    4c48:	f5ad 6dc4 	sub.w	sp, sp, #1568	; 0x620
    4c4c:	b083      	sub	sp, #12
    4c4e:	4691      	mov	r9, r2
    4c50:	af00      	add	r7, sp, #0
    4c52:	4a98      	ldr	r2, [pc, #608]	; (4eb4 <main@@Base+0x2cb8>)
    4c54:	60bb      	str	r3, [r7, #8]
    4c56:	4b98      	ldr	r3, [pc, #608]	; (4eb8 <main@@Base+0x2cbc>)
    4c58:	60f9      	str	r1, [r7, #12]
    4c5a:	447b      	add	r3, pc
    4c5c:	f8d7 5654 	ldr.w	r5, [r7, #1620]	; 0x654
    4c60:	f8d7 a650 	ldr.w	sl, [r7, #1616]	; 0x650
    4c64:	589c      	ldr	r4, [r3, r2]
    4c66:	6823      	ldr	r3, [r4, #0]
    4c68:	f8c7 3624 	str.w	r3, [r7, #1572]	; 0x624
    4c6c:	f7ff fde4 	bl	4838 <main@@Base+0x263c>
    4c70:	603c      	str	r4, [r7, #0]
    4c72:	4606      	mov	r6, r0
    4c74:	6028      	str	r0, [r5, #0]
    4c76:	2800      	cmp	r0, #0
    4c78:	f040 8109 	bne.w	4e8e <main@@Base+0x2c92>
    4c7c:	488f      	ldr	r0, [pc, #572]	; (4ebc <main@@Base+0x2cc0>)
    4c7e:	2102      	movs	r1, #2
    4c80:	4478      	add	r0, pc
    4c82:	f7fd ea2a 	blx	20d8 <open@plt>
    4c86:	1c42      	adds	r2, r0, #1
    4c88:	4604      	mov	r4, r0
    4c8a:	d106      	bne.n	4c9a <main@@Base+0x2a9e>
    4c8c:	498c      	ldr	r1, [pc, #560]	; (4ec0 <main@@Base+0x2cc4>)
    4c8e:	2002      	movs	r0, #2
    4c90:	4626      	mov	r6, r4
    4c92:	4479      	add	r1, pc
    4c94:	f7ff fa58 	bl	4148 <main@@Base+0x1f4c>
    4c98:	e0fb      	b.n	4e92 <main@@Base+0x2c96>
    4c9a:	4629      	mov	r1, r5
    4c9c:	f107 0030 	add.w	r0, r7, #48	; 0x30
    4ca0:	f7ff fecc 	bl	4a3c <main@@Base+0x2840>
    4ca4:	f109 030f 	add.w	r3, r9, #15
    4ca8:	f023 0307 	bic.w	r3, r3, #7
    4cac:	464a      	mov	r2, r9
    4cae:	ebad 0d03 	sub.w	sp, sp, r3
    4cb2:	68f9      	ldr	r1, [r7, #12]
    4cb4:	f8c7 d004 	str.w	sp, [r7, #4]
    4cb8:	466b      	mov	r3, sp
    4cba:	ea4f 08d3 	mov.w	r8, r3, lsr #3
    4cbe:	ea4f 0bc8 	mov.w	fp, r8, lsl #3
    4cc2:	4658      	mov	r0, fp
    4cc4:	f7fd e99a 	blx	1ffc <strncpy@plt>
    4cc8:	f107 0014 	add.w	r0, r7, #20
    4ccc:	4631      	mov	r1, r6
    4cce:	f809 6038 	strb.w	r6, [r9, r8, lsl #3]
    4cd2:	f7fd ea76 	blx	21c0 <pps_encoder_initialize@plt>
    4cd6:	497b      	ldr	r1, [pc, #492]	; (4ec4 <main@@Base+0x2cc8>)
    4cd8:	4a7b      	ldr	r2, [pc, #492]	; (4ec8 <main@@Base+0x2ccc>)
    4cda:	f107 0014 	add.w	r0, r7, #20
    4cde:	4479      	add	r1, pc
    4ce0:	447a      	add	r2, pc
    4ce2:	f7fd e93a 	blx	1f58 <pps_encoder_add_string@plt>
    4ce6:	4979      	ldr	r1, [pc, #484]	; (4ecc <main@@Base+0x2cd0>)
    4ce8:	4a79      	ldr	r2, [pc, #484]	; (4ed0 <main@@Base+0x2cd4>)
    4cea:	f107 0014 	add.w	r0, r7, #20
    4cee:	4479      	add	r1, pc
    4cf0:	447a      	add	r2, pc
    4cf2:	f7fd e932 	blx	1f58 <pps_encoder_add_string@plt>
    4cf6:	4977      	ldr	r1, [pc, #476]	; (4ed4 <main@@Base+0x2cd8>)
    4cf8:	f107 0014 	add.w	r0, r7, #20
    4cfc:	4479      	add	r1, pc
    4cfe:	f7fd e858 	blx	1db0 <pps_encoder_start_object@plt>
    4d02:	4975      	ldr	r1, [pc, #468]	; (4ed8 <main@@Base+0x2cdc>)
    4d04:	f107 0014 	add.w	r0, r7, #20
    4d08:	2201      	movs	r2, #1
    4d0a:	4479      	add	r1, pc
    4d0c:	f7fc efb8 	blx	1c80 <pps_encoder_add_int@plt>
    4d10:	f1ba 0f00 	cmp.w	sl, #0
    4d14:	d01a      	beq.n	4d4c <main@@Base+0x2b50>
    4d16:	f10a 030f 	add.w	r3, sl, #15
    4d1a:	4652      	mov	r2, sl
    4d1c:	f023 0307 	bic.w	r3, r3, #7
    4d20:	ebad 0d03 	sub.w	sp, sp, r3
    4d24:	4669      	mov	r1, sp
    4d26:	ea4f 09d1 	mov.w	r9, r1, lsr #3
    4d2a:	68b9      	ldr	r1, [r7, #8]
    4d2c:	ea4f 08c9 	mov.w	r8, r9, lsl #3
    4d30:	4640      	mov	r0, r8
    4d32:	f7fd e964 	blx	1ffc <strncpy@plt>
    4d36:	4969      	ldr	r1, [pc, #420]	; (4edc <main@@Base+0x2ce0>)
    4d38:	f80a 6039 	strb.w	r6, [sl, r9, lsl #3]
    4d3c:	f107 0014 	add.w	r0, r7, #20
    4d40:	4479      	add	r1, pc
    4d42:	4642      	mov	r2, r8
    4d44:	f7fd e908 	blx	1f58 <pps_encoder_add_string@plt>
    4d48:	687b      	ldr	r3, [r7, #4]
    4d4a:	469d      	mov	sp, r3
    4d4c:	4964      	ldr	r1, [pc, #400]	; (4ee0 <main@@Base+0x2ce4>)
    4d4e:	465a      	mov	r2, fp
    4d50:	f107 0014 	add.w	r0, r7, #20
    4d54:	4479      	add	r1, pc
    4d56:	f7fd e900 	blx	1f58 <pps_encoder_add_string@plt>
    4d5a:	f107 0014 	add.w	r0, r7, #20
    4d5e:	f7fd e9a4 	blx	20a8 <pps_encoder_end_object@plt>
    4d62:	f107 0014 	add.w	r0, r7, #20
    4d66:	f7fd e880 	blx	1e68 <pps_encoder_buffer@plt>
    4d6a:	2800      	cmp	r0, #0
    4d6c:	d040      	beq.n	4df0 <main@@Base+0x2bf4>
    4d6e:	f107 0014 	add.w	r0, r7, #20
    4d72:	f7fd e922 	blx	1fb8 <pps_encoder_length@plt>
    4d76:	4606      	mov	r6, r0
    4d78:	f107 0014 	add.w	r0, r7, #20
    4d7c:	f7fd e874 	blx	1e68 <pps_encoder_buffer@plt>
    4d80:	4632      	mov	r2, r6
    4d82:	4601      	mov	r1, r0
    4d84:	4620      	mov	r0, r4
    4d86:	f7fd e90c 	blx	1fa0 <write@plt>
    4d8a:	42b0      	cmp	r0, r6
    4d8c:	d00a      	beq.n	4da4 <main@@Base+0x2ba8>
    4d8e:	f107 0014 	add.w	r0, r7, #20
    4d92:	f7fd e86a 	blx	1e68 <pps_encoder_buffer@plt>
    4d96:	4953      	ldr	r1, [pc, #332]	; (4ee4 <main@@Base+0x2ce8>)
    4d98:	4479      	add	r1, pc
    4d9a:	4602      	mov	r2, r0
    4d9c:	2002      	movs	r0, #2
    4d9e:	f7ff f9d3 	bl	4148 <main@@Base+0x1f4c>
    4da2:	e02a      	b.n	4dfa <main@@Base+0x2bfe>
    4da4:	f507 6184 	add.w	r1, r7, #1056	; 0x420
    4da8:	f240 12ff 	movw	r2, #511	; 0x1ff
    4dac:	3104      	adds	r1, #4
    4dae:	4620      	mov	r0, r4
    4db0:	f7fd e84e 	blx	1e50 <read@plt>
    4db4:	2100      	movs	r1, #0
    4db6:	460a      	mov	r2, r1
    4db8:	4606      	mov	r6, r0
    4dba:	f107 0050 	add.w	r0, r7, #80	; 0x50
    4dbe:	f7fc ef5a 	blx	1c74 <pps_decoder_init@plt>
    4dc2:	f507 6184 	add.w	r1, r7, #1056	; 0x420
    4dc6:	4632      	mov	r2, r6
    4dc8:	3104      	adds	r1, #4
    4dca:	f107 0050 	add.w	r0, r7, #80	; 0x50
    4dce:	f7fc efcc 	blx	1d68 <pps_decoder_parse@plt>
    4dd2:	2100      	movs	r1, #0
    4dd4:	f107 0050 	add.w	r0, r7, #80	; 0x50
    4dd8:	f7fc ef9c 	blx	1d14 <pps_decoder_push@plt>
    4ddc:	4942      	ldr	r1, [pc, #264]	; (4ee8 <main@@Base+0x2cec>)
    4dde:	f107 0050 	add.w	r0, r7, #80	; 0x50
    4de2:	f107 0248 	add.w	r2, r7, #72	; 0x48
    4de6:	4479      	add	r1, pc
    4de8:	f7fd e97c 	blx	20e4 <pps_decoder_get_string@plt>
    4dec:	b140      	cbz	r0, 4e00 <main@@Base+0x2c04>
    4dee:	e00e      	b.n	4e0e <main@@Base+0x2c12>
    4df0:	493e      	ldr	r1, [pc, #248]	; (4eec <main@@Base+0x2cf0>)
    4df2:	2002      	movs	r0, #2
    4df4:	4479      	add	r1, pc
    4df6:	f7ff f9a7 	bl	4148 <main@@Base+0x1f4c>
    4dfa:	f04f 36ff 	mov.w	r6, #4294967295	; 0xffffffff
    4dfe:	e03a      	b.n	4e76 <main@@Base+0x2c7a>
    4e00:	6cb8      	ldr	r0, [r7, #72]	; 0x48
    4e02:	b120      	cbz	r0, 4e0e <main@@Base+0x2c12>
    4e04:	493a      	ldr	r1, [pc, #232]	; (4ef0 <main@@Base+0x2cf4>)
    4e06:	4479      	add	r1, pc
    4e08:	f7fd e9ec 	blx	21e4 <strcmp@plt>
    4e0c:	b118      	cbz	r0, 4e16 <main@@Base+0x2c1a>
    4e0e:	4939      	ldr	r1, [pc, #228]	; (4ef4 <main@@Base+0x2cf8>)
    4e10:	2002      	movs	r0, #2
    4e12:	4479      	add	r1, pc
    4e14:	e7ef      	b.n	4df6 <main@@Base+0x2bfa>
    4e16:	4e38      	ldr	r6, [pc, #224]	; (4ef8 <main@@Base+0x2cfc>)
    4e18:	f107 0050 	add.w	r0, r7, #80	; 0x50
    4e1c:	447e      	add	r6, pc
    4e1e:	4631      	mov	r1, r6
    4e20:	f7fd e85e 	blx	1ee0 <pps_decoder_type@plt>
    4e24:	2802      	cmp	r0, #2
    4e26:	d00e      	beq.n	4e46 <main@@Base+0x2c4a>
    4e28:	2803      	cmp	r0, #3
    4e2a:	d119      	bne.n	4e60 <main@@Base+0x2c64>
    4e2c:	4631      	mov	r1, r6
    4e2e:	f107 024c 	add.w	r2, r7, #76	; 0x4c
    4e32:	f107 0050 	add.w	r0, r7, #80	; 0x50
    4e36:	f7fd e956 	blx	20e4 <pps_decoder_get_string@plt>
    4e3a:	4606      	mov	r6, r0
    4e3c:	6cf8      	ldr	r0, [r7, #76]	; 0x4c
    4e3e:	f7fd e82c 	blx	1e98 <atoi@plt>
    4e42:	6028      	str	r0, [r5, #0]
    4e44:	e006      	b.n	4e54 <main@@Base+0x2c58>
    4e46:	4631      	mov	r1, r6
    4e48:	f107 0050 	add.w	r0, r7, #80	; 0x50
    4e4c:	462a      	mov	r2, r5
    4e4e:	f7fc ee9c 	blx	1b88 <pps_decoder_get_int@plt>
    4e52:	4606      	mov	r6, r0
    4e54:	2e03      	cmp	r6, #3
    4e56:	d003      	beq.n	4e60 <main@@Base+0x2c64>
    4e58:	4928      	ldr	r1, [pc, #160]	; (4efc <main@@Base+0x2d00>)
    4e5a:	2002      	movs	r0, #2
    4e5c:	4479      	add	r1, pc
    4e5e:	e7ca      	b.n	4df6 <main@@Base+0x2bfa>
    4e60:	4927      	ldr	r1, [pc, #156]	; (4f00 <main@@Base+0x2d04>)
    4e62:	2005      	movs	r0, #5
    4e64:	2600      	movs	r6, #0
    4e66:	602e      	str	r6, [r5, #0]
    4e68:	4479      	add	r1, pc
    4e6a:	f7ff f96d 	bl	4148 <main@@Base+0x1f4c>
    4e6e:	f107 0050 	add.w	r0, r7, #80	; 0x50
    4e72:	f7fd e914 	blx	209c <pps_decoder_pop@plt>
    4e76:	4620      	mov	r0, r4
    4e78:	f7fc eea0 	blx	1bbc <close@plt+0x4>
    4e7c:	f107 0014 	add.w	r0, r7, #20
    4e80:	f7fc efec 	blx	1e5c <pps_encoder_cleanup@plt>
    4e84:	f107 0050 	add.w	r0, r7, #80	; 0x50
    4e88:	f7fd e920 	blx	20cc <pps_decoder_cleanup@plt>
    4e8c:	e001      	b.n	4e92 <main@@Base+0x2c96>
    4e8e:	f04f 36ff 	mov.w	r6, #4294967295	; 0xffffffff
    4e92:	6839      	ldr	r1, [r7, #0]
    4e94:	4630      	mov	r0, r6
    4e96:	f8d7 2624 	ldr.w	r2, [r7, #1572]	; 0x624
    4e9a:	680b      	ldr	r3, [r1, #0]
    4e9c:	429a      	cmp	r2, r3
    4e9e:	d001      	beq.n	4ea4 <main@@Base+0x2ca8>
    4ea0:	f7fc ef5c 	blx	1d5c <__stack_chk_fail@plt>
    4ea4:	f507 770b 	add.w	r7, r7, #556	; 0x22c
    4ea8:	f507 6780 	add.w	r7, r7, #1024	; 0x400
    4eac:	46bd      	mov	sp, r7
    4eae:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
    4eb2:	bf00      	nop
    4eb4:	0258      	lsls	r0, r3, #9
    4eb6:	0000      	movs	r0, r0
    4eb8:	43a2      	bics	r2, r4
    4eba:	0000      	movs	r0, r0
    4ebc:	1e3a      	subs	r2, r7, #0
    4ebe:	0000      	movs	r0, r0
    4ec0:	1fbd      	subs	r5, r7, #6
    4ec2:	0000      	movs	r0, r0
    4ec4:	1e4e      	subs	r6, r1, #1
    4ec6:	0000      	movs	r0, r0
    4ec8:	2024      	movs	r0, #36	; 0x24
    4eca:	0000      	movs	r0, r0
    4ecc:	2098      	movs	r0, #152	; 0x98
    4ece:	0000      	movs	r0, r0
    4ed0:	1e47      	subs	r7, r0, #1
    4ed2:	0000      	movs	r0, r0
    4ed4:	1e8e      	subs	r6, r1, #2
    4ed6:	0000      	movs	r0, r0
    4ed8:	2003      	movs	r0, #3
    4eda:	0000      	movs	r0, r0
    4edc:	1158      	asrs	r0, r3, #5
    4ede:	0000      	movs	r0, r0
    4ee0:	1fc0      	subs	r0, r0, #7
    4ee2:	0000      	movs	r0, r0
    4ee4:	1da2      	adds	r2, r4, #6
    4ee6:	0000      	movs	r0, r0
    4ee8:	1fa0      	subs	r0, r4, #6
    4eea:	0000      	movs	r0, r0
    4eec:	1d60      	adds	r0, r4, #5
    4eee:	0000      	movs	r0, r0
    4ef0:	1d31      	adds	r1, r6, #4
    4ef2:	0000      	movs	r0, r0
    4ef4:	1d56      	adds	r6, r2, #5
    4ef6:	0000      	movs	r0, r0
    4ef8:	1d6a      	adds	r2, r5, #5
    4efa:	0000      	movs	r0, r0
    4efc:	1ebd      	subs	r5, r7, #2
    4efe:	0000      	movs	r0, r0
    4f00:	1edb      	subs	r3, r3, #3
    4f02:	0000      	movs	r0, r0
    4f04:	b5f8      	push	{r3, r4, r5, r6, r7, lr}
    4f06:	4605      	mov	r5, r0
    4f08:	4820      	ldr	r0, [pc, #128]	; (4f8c <main@@Base+0x2d90>)
    4f0a:	460c      	mov	r4, r1
    4f0c:	2100      	movs	r1, #0
    4f0e:	4478      	add	r0, pc
    4f10:	f7fd e8e2 	blx	20d8 <open@plt>
    4f14:	1c41      	adds	r1, r0, #1
    4f16:	4606      	mov	r6, r0
    4f18:	d034      	beq.n	4f84 <main@@Base+0x2d88>
    4f1a:	4629      	mov	r1, r5
    4f1c:	4622      	mov	r2, r4
    4f1e:	f7fc ef98 	blx	1e50 <read@plt>
    4f22:	4607      	mov	r7, r0
    4f24:	4630      	mov	r0, r6
    4f26:	f7fc ee4a 	blx	1bbc <close@plt+0x4>
    4f2a:	42a7      	cmp	r7, r4
    4f2c:	bf2c      	ite	cs
    4f2e:	2300      	movcs	r3, #0
    4f30:	2301      	movcc	r3, #1
    4f32:	ea53 73d7 	orrs.w	r3, r3, r7, lsr #31
    4f36:	d01b      	beq.n	4f70 <main@@Base+0x2d74>
    4f38:	e026      	b.n	4f88 <main@@Base+0x2d8c>
    4f3a:	3c01      	subs	r4, #1
    4f3c:	2103      	movs	r1, #3
    4f3e:	5d2e      	ldrb	r6, [r5, r4]
    4f40:	0930      	lsrs	r0, r6, #4
    4f42:	f7fd e888 	blx	2054 <__aeabi_uidivmod@plt>
    4f46:	4630      	mov	r0, r6
    4f48:	b2c9      	uxtb	r1, r1
    4f4a:	2901      	cmp	r1, #1
    4f4c:	d006      	beq.n	4f5c <main@@Base+0x2d60>
    4f4e:	2902      	cmp	r1, #2
    4f50:	d009      	beq.n	4f66 <main@@Base+0x2d6a>
    4f52:	210a      	movs	r1, #10
    4f54:	f7fd e87e 	blx	2054 <__aeabi_uidivmod@plt>
    4f58:	3130      	adds	r1, #48	; 0x30
    4f5a:	e008      	b.n	4f6e <main@@Base+0x2d72>
    4f5c:	211a      	movs	r1, #26
    4f5e:	f7fd e87a 	blx	2054 <__aeabi_uidivmod@plt>
    4f62:	3161      	adds	r1, #97	; 0x61
    4f64:	e003      	b.n	4f6e <main@@Base+0x2d72>
    4f66:	211a      	movs	r1, #26
    4f68:	f7fd e874 	blx	2054 <__aeabi_uidivmod@plt>
    4f6c:	3141      	adds	r1, #65	; 0x41
    4f6e:	5529      	strb	r1, [r5, r4]
    4f70:	2c00      	cmp	r4, #0
    4f72:	d1e2      	bne.n	4f3a <main@@Base+0x2d3e>
    4f74:	4906      	ldr	r1, [pc, #24]	; (4f90 <main@@Base+0x2d94>)
    4f76:	4628      	mov	r0, r5
    4f78:	2233      	movs	r2, #51	; 0x33
    4f7a:	4479      	add	r1, pc
    4f7c:	f7fc eec4 	blx	1d08 <memcpy@plt+0x4>
    4f80:	2001      	movs	r0, #1
    4f82:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
    4f84:	2000      	movs	r0, #0
    4f86:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
    4f88:	2000      	movs	r0, #0
    4f8a:	bdf8      	pop	{r3, r4, r5, r6, r7, pc}
    4f8c:	1e7b      	subs	r3, r7, #1
    4f8e:	0000      	movs	r0, r0
    4f90:	1e1b      	subs	r3, r3, #0
    4f92:	0000      	movs	r0, r0
    4f94:	4b4f      	ldr	r3, [pc, #316]	; (50d4 <main@@Base+0x2ed8>)
    4f96:	e92d 43f0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, lr}
    4f9a:	b087      	sub	sp, #28
    4f9c:	4a4e      	ldr	r2, [pc, #312]	; (50d8 <main@@Base+0x2edc>)
    4f9e:	447b      	add	r3, pc
    4fa0:	af00      	add	r7, sp, #0
    4fa2:	2500      	movs	r5, #0
    4fa4:	6078      	str	r0, [r7, #4]
    4fa6:	2004      	movs	r0, #4
    4fa8:	f853 8002 	ldr.w	r8, [r3, r2]
    4fac:	f8d8 3000 	ldr.w	r3, [r8]
    4fb0:	617b      	str	r3, [r7, #20]
    4fb2:	f7fc ee90 	blx	1cd4 <sysconf@plt>
    4fb6:	60fd      	str	r5, [r7, #12]
    4fb8:	0083      	lsls	r3, r0, #2
    4fba:	4606      	mov	r6, r0
    4fbc:	6878      	ldr	r0, [r7, #4]
    4fbe:	330e      	adds	r3, #14
    4fc0:	f023 0307 	bic.w	r3, r3, #7
    4fc4:	ebad 0d03 	sub.w	sp, sp, r3
    4fc8:	7803      	ldrb	r3, [r0, #0]
    4fca:	466c      	mov	r4, sp
    4fcc:	3b30      	subs	r3, #48	; 0x30
    4fce:	b2db      	uxtb	r3, r3
    4fd0:	2b09      	cmp	r3, #9
    4fd2:	d82c      	bhi.n	502e <main@@Base+0x2e32>
    4fd4:	1d39      	adds	r1, r7, #4
    4fd6:	462a      	mov	r2, r5
    4fd8:	f7fd e8c2 	blx	2160 <strtol@plt>
    4fdc:	4681      	mov	r9, r0
    4fde:	6878      	ldr	r0, [r7, #4]
    4fe0:	f810 3b01 	ldrb.w	r3, [r0], #1
    4fe4:	2b3a      	cmp	r3, #58	; 0x3a
    4fe6:	6078      	str	r0, [r7, #4]
    4fe8:	d11f      	bne.n	502a <main@@Base+0x2e2e>
    4fea:	1d39      	adds	r1, r7, #4
    4fec:	462a      	mov	r2, r5
    4fee:	f7fd e8b8 	blx	2160 <strtol@plt>
    4ff2:	f7fd e8b0 	blx	2154 <setgid@plt>
    4ff6:	1c43      	adds	r3, r0, #1
    4ff8:	d108      	bne.n	500c <main@@Base+0x2e10>
    4ffa:	e05f      	b.n	50bc <main@@Base+0x2ec0>
    4ffc:	1d39      	adds	r1, r7, #4
    4ffe:	2200      	movs	r2, #0
    5000:	f7fd e8ae 	blx	2160 <strtol@plt>
    5004:	f844 0025 	str.w	r0, [r4, r5, lsl #2]
    5008:	3501      	adds	r5, #1
    500a:	60fd      	str	r5, [r7, #12]
    500c:	68fd      	ldr	r5, [r7, #12]
    500e:	42b5      	cmp	r5, r6
    5010:	d205      	bcs.n	501e <main@@Base+0x2e22>
    5012:	6878      	ldr	r0, [r7, #4]
    5014:	f810 3b01 	ldrb.w	r3, [r0], #1
    5018:	2b2c      	cmp	r3, #44	; 0x2c
    501a:	6078      	str	r0, [r7, #4]
    501c:	d0ee      	beq.n	4ffc <main@@Base+0x2e00>
    501e:	4621      	mov	r1, r4
    5020:	4628      	mov	r0, r5
    5022:	f7fc efc4 	blx	1fac <setgroups@plt>
    5026:	1c41      	adds	r1, r0, #1
    5028:	d048      	beq.n	50bc <main@@Base+0x2ec0>
    502a:	4648      	mov	r0, r9
    502c:	e037      	b.n	509e <main@@Base+0x2ea2>
    502e:	212c      	movs	r1, #44	; 0x2c
    5030:	f7fc edd0 	blx	1bd4 <strchr@plt>
    5034:	6138      	str	r0, [r7, #16]
    5036:	b100      	cbz	r0, 503a <main@@Base+0x2e3e>
    5038:	7005      	strb	r5, [r0, #0]
    503a:	6878      	ldr	r0, [r7, #4]
    503c:	f7fd e828 	blx	2090 <getpwnam@plt>
    5040:	4605      	mov	r5, r0
    5042:	2800      	cmp	r0, #0
    5044:	d034      	beq.n	50b0 <main@@Base+0x2eb4>
    5046:	68c0      	ldr	r0, [r0, #12]
    5048:	f7fd e884 	blx	2154 <setgid@plt>
    504c:	1c42      	adds	r2, r0, #1
    504e:	d035      	beq.n	50bc <main@@Base+0x2ec0>
    5050:	f107 030c 	add.w	r3, r7, #12
    5054:	6878      	ldr	r0, [r7, #4]
    5056:	68e9      	ldr	r1, [r5, #12]
    5058:	4622      	mov	r2, r4
    505a:	f7fd e8a0 	blx	219c <getgrouplist@plt>
    505e:	693b      	ldr	r3, [r7, #16]
    5060:	b1b3      	cbz	r3, 5090 <main@@Base+0x2e94>
    5062:	222c      	movs	r2, #44	; 0x2c
    5064:	701a      	strb	r2, [r3, #0]
    5066:	e009      	b.n	507c <main@@Base+0x2e80>
    5068:	f107 0110 	add.w	r1, r7, #16
    506c:	2200      	movs	r2, #0
    506e:	f7fd e878 	blx	2160 <strtol@plt>
    5072:	f109 0301 	add.w	r3, r9, #1
    5076:	60fb      	str	r3, [r7, #12]
    5078:	f844 0029 	str.w	r0, [r4, r9, lsl #2]
    507c:	f8d7 900c 	ldr.w	r9, [r7, #12]
    5080:	45b1      	cmp	r9, r6
    5082:	d205      	bcs.n	5090 <main@@Base+0x2e94>
    5084:	6938      	ldr	r0, [r7, #16]
    5086:	f810 3b01 	ldrb.w	r3, [r0], #1
    508a:	2b2c      	cmp	r3, #44	; 0x2c
    508c:	6138      	str	r0, [r7, #16]
    508e:	d0eb      	beq.n	5068 <main@@Base+0x2e6c>
    5090:	68f8      	ldr	r0, [r7, #12]
    5092:	4621      	mov	r1, r4
    5094:	f7fc ef8a 	blx	1fac <setgroups@plt>
    5098:	1c43      	adds	r3, r0, #1
    509a:	d00f      	beq.n	50bc <main@@Base+0x2ec0>
    509c:	68a8      	ldr	r0, [r5, #8]
    509e:	f7fc ee58 	blx	1d50 <setuid@plt>
    50a2:	f1b0 3fff 	cmp.w	r0, #4294967295	; 0xffffffff
    50a6:	bf0c      	ite	eq
    50a8:	f04f 30ff 	moveq.w	r0, #4294967295	; 0xffffffff
    50ac:	2000      	movne	r0, #0
    50ae:	e005      	b.n	50bc <main@@Base+0x2ec0>
    50b0:	f7fc edae 	blx	1c10 <__get_errno_ptr@plt>
    50b4:	2316      	movs	r3, #22
    50b6:	6003      	str	r3, [r0, #0]
    50b8:	f04f 30ff 	mov.w	r0, #4294967295	; 0xffffffff
    50bc:	697a      	ldr	r2, [r7, #20]
    50be:	f8d8 3000 	ldr.w	r3, [r8]
    50c2:	429a      	cmp	r2, r3
    50c4:	d001      	beq.n	50ca <main@@Base+0x2ece>
    50c6:	f7fc ee4a 	blx	1d5c <__stack_chk_fail@plt>
    50ca:	f107 071c 	add.w	r7, r7, #28
    50ce:	46bd      	mov	sp, r7
    50d0:	e8bd 83f0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, pc}
    50d4:	405e      	eors	r6, r3
    50d6:	0000      	movs	r0, r0
    50d8:	0258      	lsls	r0, r3, #9
    50da:	0000      	movs	r0, r0
    50dc:	4603      	mov	r3, r0
    50de:	480e      	ldr	r0, [pc, #56]	; (5118 <main@@Base+0x2f1c>)
    50e0:	b570      	push	{r4, r5, r6, lr}
    50e2:	4478      	add	r0, pc
    50e4:	4615      	mov	r5, r2
    50e6:	2400      	movs	r4, #0
    50e8:	e00d      	b.n	5106 <main@@Base+0x2f0a>
    50ea:	5d1e      	ldrb	r6, [r3, r4]
    50ec:	0936      	lsrs	r6, r6, #4
    50ee:	f850 6026 	ldr.w	r6, [r0, r6, lsl #2]
    50f2:	f805 6c02 	strb.w	r6, [r5, #-2]
    50f6:	5d1e      	ldrb	r6, [r3, r4]
    50f8:	3401      	adds	r4, #1
    50fa:	f006 060f 	and.w	r6, r6, #15
    50fe:	f850 6026 	ldr.w	r6, [r0, r6, lsl #2]
    5102:	f805 6c01 	strb.w	r6, [r5, #-1]
    5106:	3502      	adds	r5, #2
    5108:	428c      	cmp	r4, r1
    510a:	d1ee      	bne.n	50ea <main@@Base+0x2eee>
    510c:	2300      	movs	r3, #0
    510e:	4610      	mov	r0, r2
    5110:	f802 3014 	strb.w	r3, [r2, r4, lsl #1]
    5114:	bd70      	pop	{r4, r5, r6, pc}
    5116:	bf00      	nop
    5118:	1cea      	adds	r2, r5, #3
    511a:	0000      	movs	r0, r0
    511c:	b5f0      	push	{r4, r5, r6, r7, lr}
    511e:	4603      	mov	r3, r0
    5120:	4d10      	ldr	r5, [pc, #64]	; (5164 <main@@Base+0x2f68>)
    5122:	4608      	mov	r0, r1
    5124:	447d      	add	r5, pc
    5126:	e016      	b.n	5156 <main@@Base+0x2f5a>
    5128:	785e      	ldrb	r6, [r3, #1]
    512a:	b264      	sxtb	r4, r4
    512c:	b93e      	cbnz	r6, 513e <main@@Base+0x2f42>
    512e:	4b0e      	ldr	r3, [pc, #56]	; (5168 <main@@Base+0x2f6c>)
    5130:	447b      	add	r3, pc
    5132:	eb03 0484 	add.w	r4, r3, r4, lsl #2
    5136:	6c23      	ldr	r3, [r4, #64]	; 0x40
    5138:	011b      	lsls	r3, r3, #4
    513a:	7003      	strb	r3, [r0, #0]
    513c:	e00e      	b.n	515c <main@@Base+0x2f60>
    513e:	b276      	sxtb	r6, r6
    5140:	eb05 0484 	add.w	r4, r5, r4, lsl #2
    5144:	3302      	adds	r3, #2
    5146:	eb05 0686 	add.w	r6, r5, r6, lsl #2
    514a:	6c27      	ldr	r7, [r4, #64]	; 0x40
    514c:	6c34      	ldr	r4, [r6, #64]	; 0x40
    514e:	eb04 1407 	add.w	r4, r4, r7, lsl #4
    5152:	f800 4b01 	strb.w	r4, [r0], #1
    5156:	781c      	ldrb	r4, [r3, #0]
    5158:	2c00      	cmp	r4, #0
    515a:	d1e5      	bne.n	5128 <main@@Base+0x2f2c>
    515c:	1a40      	subs	r0, r0, r1
    515e:	6010      	str	r0, [r2, #0]
    5160:	4608      	mov	r0, r1
    5162:	bdf0      	pop	{r4, r5, r6, r7, pc}
    5164:	1ca8      	adds	r0, r5, #2
    5166:	0000      	movs	r0, r0
    5168:	1c9c      	adds	r4, r3, #2
    516a:	0000      	movs	r0, r0
    516c:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
    5170:	b089      	sub	sp, #36	; 0x24
    5172:	af00      	add	r7, sp, #0
    5174:	4605      	mov	r5, r0
    5176:	e9c7 2304 	strd	r2, r3, [r7, #16]
    517a:	4b51      	ldr	r3, [pc, #324]	; (52c0 <main@@Base+0x30c4>)
    517c:	6cb9      	ldr	r1, [r7, #72]	; 0x48
    517e:	4a51      	ldr	r2, [pc, #324]	; (52c4 <main@@Base+0x30c8>)
    5180:	447b      	add	r3, pc
    5182:	f8d7 9050 	ldr.w	r9, [r7, #80]	; 0x50
    5186:	6079      	str	r1, [r7, #4]
    5188:	589b      	ldr	r3, [r3, r2]
    518a:	f1b9 0f40 	cmp.w	r9, #64	; 0x40
    518e:	bf2c      	ite	cs
    5190:	4649      	movcs	r1, r9
    5192:	2140      	movcc	r1, #64	; 0x40
    5194:	f8d7 a04c 	ldr.w	sl, [r7, #76]	; 0x4c
    5198:	6d7e      	ldr	r6, [r7, #84]	; 0x54
    519a:	681a      	ldr	r2, [r3, #0]
    519c:	f8d7 b058 	ldr.w	fp, [r7, #88]	; 0x58
    51a0:	603b      	str	r3, [r7, #0]
    51a2:	61fa      	str	r2, [r7, #28]
    51a4:	f101 020c 	add.w	r2, r1, #12
    51a8:	311a      	adds	r1, #26
    51aa:	2801      	cmp	r0, #1
    51ac:	f021 0107 	bic.w	r1, r1, #7
    51b0:	ebad 0d01 	sub.w	sp, sp, r1
    51b4:	466c      	mov	r4, sp
    51b6:	d101      	bne.n	51bc <main@@Base+0x2fc0>
    51b8:	2314      	movs	r3, #20
    51ba:	e002      	b.n	51c2 <main@@Base+0x2fc6>
    51bc:	2802      	cmp	r0, #2
    51be:	d107      	bne.n	51d0 <main@@Base+0x2fd4>
    51c0:	2340      	movs	r3, #64	; 0x40
    51c2:	61bb      	str	r3, [r7, #24]
    51c4:	f8db 1000 	ldr.w	r1, [fp]
    51c8:	69bb      	ldr	r3, [r7, #24]
    51ca:	4299      	cmp	r1, r3
    51cc:	d209      	bcs.n	51e2 <main@@Base+0x2fe6>
    51ce:	e003      	b.n	51d8 <main@@Base+0x2fdc>
    51d0:	f7fc ed1e 	blx	1c10 <__get_errno_ptr@plt>
    51d4:	2316      	movs	r3, #22
    51d6:	e002      	b.n	51de <main@@Base+0x2fe2>
    51d8:	f7fc ed1a 	blx	1c10 <__get_errno_ptr@plt>
    51dc:	2322      	movs	r3, #34	; 0x22
    51de:	6003      	str	r3, [r0, #0]
    51e0:	e060      	b.n	52a4 <main@@Base+0x30a8>
    51e2:	2100      	movs	r1, #0
    51e4:	46a0      	mov	r8, r4
    51e6:	4620      	mov	r0, r4
    51e8:	f7fc edf6 	blx	1dd8 <memset@plt+0x4>
    51ec:	2300      	movs	r3, #0
    51ee:	f848 3b04 	str.w	r3, [r8], #4
    51f2:	f107 0310 	add.w	r3, r7, #16
    51f6:	60fb      	str	r3, [r7, #12]
    51f8:	464a      	mov	r2, r9
    51fa:	e893 0003 	ldmia.w	r3, {r0, r1}
    51fe:	e888 0003 	stmia.w	r8, {r0, r1}
    5202:	f104 010c 	add.w	r1, r4, #12
    5206:	60b9      	str	r1, [r7, #8]
    5208:	4608      	mov	r0, r1
    520a:	4651      	mov	r1, sl
    520c:	f7fc ed7c 	blx	1d08 <memcpy@plt+0x4>
    5210:	2d01      	cmp	r5, #1
    5212:	d108      	bne.n	5226 <main@@Base+0x302a>
    5214:	f109 010c 	add.w	r1, r9, #12
    5218:	4620      	mov	r0, r4
    521a:	4632      	mov	r2, r6
    521c:	f107 0318 	add.w	r3, r7, #24
    5220:	f000 f9c6 	bl	55b0 <main@@Base+0x33b4>
    5224:	e009      	b.n	523a <main@@Base+0x303e>
    5226:	2d02      	cmp	r5, #2
    5228:	d109      	bne.n	523e <main@@Base+0x3042>
    522a:	f109 010c 	add.w	r1, r9, #12
    522e:	4620      	mov	r0, r4
    5230:	4632      	mov	r2, r6
    5232:	f107 0318 	add.w	r3, r7, #24
    5236:	f000 f975 	bl	5524 <main@@Base+0x3328>
    523a:	2800      	cmp	r0, #0
    523c:	db32      	blt.n	52a4 <main@@Base+0x30a8>
    523e:	f04f 0a01 	mov.w	sl, #1
    5242:	46c1      	mov	r9, r8
    5244:	e026      	b.n	5294 <main@@Base+0x3098>
    5246:	68fb      	ldr	r3, [r7, #12]
    5248:	f8c4 a000 	str.w	sl, [r4]
    524c:	e893 0003 	ldmia.w	r3, {r0, r1}
    5250:	e889 0003 	stmia.w	r9, {r0, r1}
    5254:	4631      	mov	r1, r6
    5256:	f8d7 8018 	ldr.w	r8, [r7, #24]
    525a:	68b8      	ldr	r0, [r7, #8]
    525c:	4642      	mov	r2, r8
    525e:	f7fc ed54 	blx	1d08 <memcpy@plt+0x4>
    5262:	2d01      	cmp	r5, #1
    5264:	d108      	bne.n	5278 <main@@Base+0x307c>
    5266:	f108 010c 	add.w	r1, r8, #12
    526a:	4620      	mov	r0, r4
    526c:	4632      	mov	r2, r6
    526e:	f107 0318 	add.w	r3, r7, #24
    5272:	f000 f99d 	bl	55b0 <main@@Base+0x33b4>
    5276:	e009      	b.n	528c <main@@Base+0x3090>
    5278:	2d02      	cmp	r5, #2
    527a:	d109      	bne.n	5290 <main@@Base+0x3094>
    527c:	f108 010c 	add.w	r1, r8, #12
    5280:	4620      	mov	r0, r4
    5282:	4632      	mov	r2, r6
    5284:	f107 0318 	add.w	r3, r7, #24
    5288:	f000 f94c 	bl	5524 <main@@Base+0x3328>
    528c:	2800      	cmp	r0, #0
    528e:	db09      	blt.n	52a4 <main@@Base+0x30a8>
    5290:	f10a 0a01 	add.w	sl, sl, #1
    5294:	6879      	ldr	r1, [r7, #4]
    5296:	458a      	cmp	sl, r1
    5298:	d3d5      	bcc.n	5246 <main@@Base+0x304a>
    529a:	69bb      	ldr	r3, [r7, #24]
    529c:	2000      	movs	r0, #0
    529e:	f8cb 3000 	str.w	r3, [fp]
    52a2:	e001      	b.n	52a8 <main@@Base+0x30ac>
    52a4:	f04f 30ff 	mov.w	r0, #4294967295	; 0xffffffff
    52a8:	6839      	ldr	r1, [r7, #0]
    52aa:	69fa      	ldr	r2, [r7, #28]
    52ac:	680b      	ldr	r3, [r1, #0]
    52ae:	429a      	cmp	r2, r3
    52b0:	d001      	beq.n	52b6 <main@@Base+0x30ba>
    52b2:	f7fc ed54 	blx	1d5c <__stack_chk_fail@plt>
    52b6:	f107 0724 	add.w	r7, r7, #36	; 0x24
    52ba:	46bd      	mov	sp, r7
    52bc:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
    52c0:	3e7c      	subs	r6, #124	; 0x7c
    52c2:	0000      	movs	r0, r0
    52c4:	0258      	lsls	r0, r3, #9
    52c6:	0000      	movs	r0, r0
    52c8:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
    52cc:	b09d      	sub	sp, #116	; 0x74
    52ce:	af06      	add	r7, sp, #24
    52d0:	4689      	mov	r9, r1
    52d2:	4605      	mov	r5, r0
    52d4:	e9c7 2302 	strd	r2, r3, [r7, #8]
    52d8:	f107 0414 	add.w	r4, r7, #20
    52dc:	4b3d      	ldr	r3, [pc, #244]	; (53d4 <main@@Base+0x31d8>)
    52de:	4a3e      	ldr	r2, [pc, #248]	; (53d8 <main@@Base+0x31dc>)
    52e0:	f8d7 1080 	ldr.w	r1, [r7, #128]	; 0x80
    52e4:	447b      	add	r3, pc
    52e6:	f8d7 6084 	ldr.w	r6, [r7, #132]	; 0x84
    52ea:	f8d7 a088 	ldr.w	sl, [r7, #136]	; 0x88
    52ee:	6079      	str	r1, [r7, #4]
    52f0:	589b      	ldr	r3, [r3, r2]
    52f2:	681a      	ldr	r2, [r3, #0]
    52f4:	603b      	str	r3, [r7, #0]
    52f6:	657a      	str	r2, [r7, #84]	; 0x54
    52f8:	2240      	movs	r2, #64	; 0x40
    52fa:	613a      	str	r2, [r7, #16]
    52fc:	f1b9 0f00 	cmp.w	r9, #0
    5300:	d109      	bne.n	5316 <main@@Base+0x311a>
    5302:	f7fc ef22 	blx	2148 <strlen@plt>
    5306:	4622      	mov	r2, r4
    5308:	f107 0310 	add.w	r3, r7, #16
    530c:	4601      	mov	r1, r0
    530e:	4628      	mov	r0, r5
    5310:	f000 f94e 	bl	55b0 <main@@Base+0x33b4>
    5314:	e010      	b.n	5338 <main@@Base+0x313c>
    5316:	f7fc ef18 	blx	2148 <strlen@plt>
    531a:	687b      	ldr	r3, [r7, #4]
    531c:	f107 0110 	add.w	r1, r7, #16
    5320:	9403      	str	r4, [sp, #12]
    5322:	9104      	str	r1, [sp, #16]
    5324:	e88d 0028 	stmia.w	sp, {r3, r5}
    5328:	9002      	str	r0, [sp, #8]
    532a:	4648      	mov	r0, r9
    532c:	e9d7 2302 	ldrd	r2, r3, [r7, #8]
    5330:	f7ff ff1c 	bl	516c <main@@Base+0x2f70>
    5334:	2800      	cmp	r0, #0
    5336:	db3e      	blt.n	53b6 <main@@Base+0x31ba>
    5338:	2e00      	cmp	r6, #0
    533a:	d036      	beq.n	53aa <main@@Base+0x31ae>
    533c:	4630      	mov	r0, r6
    533e:	46eb      	mov	fp, sp
    5340:	f7fc ef02 	blx	2148 <strlen@plt>
    5344:	693b      	ldr	r3, [r7, #16]
    5346:	4631      	mov	r1, r6
    5348:	18c3      	adds	r3, r0, r3
    534a:	4605      	mov	r5, r0
    534c:	330e      	adds	r3, #14
    534e:	462a      	mov	r2, r5
    5350:	f023 0307 	bic.w	r3, r3, #7
    5354:	ebad 0d03 	sub.w	sp, sp, r3
    5358:	f10d 0818 	add.w	r8, sp, #24
    535c:	4640      	mov	r0, r8
    535e:	f7fc ecd4 	blx	1d08 <memcpy@plt+0x4>
    5362:	693e      	ldr	r6, [r7, #16]
    5364:	4621      	mov	r1, r4
    5366:	eb08 0005 	add.w	r0, r8, r5
    536a:	4632      	mov	r2, r6
    536c:	f7fc eccc 	blx	1d08 <memcpy@plt+0x4>
    5370:	19a9      	adds	r1, r5, r6
    5372:	f1b9 0f00 	cmp.w	r9, #0
    5376:	d106      	bne.n	5386 <main@@Base+0x318a>
    5378:	4640      	mov	r0, r8
    537a:	4622      	mov	r2, r4
    537c:	f107 0310 	add.w	r3, r7, #16
    5380:	f000 f916 	bl	55b0 <main@@Base+0x33b4>
    5384:	e010      	b.n	53a8 <main@@Base+0x31ac>
    5386:	687b      	ldr	r3, [r7, #4]
    5388:	4648      	mov	r0, r9
    538a:	9102      	str	r1, [sp, #8]
    538c:	f107 0110 	add.w	r1, r7, #16
    5390:	9403      	str	r4, [sp, #12]
    5392:	9104      	str	r1, [sp, #16]
    5394:	e88d 0108 	stmia.w	sp, {r3, r8}
    5398:	e9d7 2302 	ldrd	r2, r3, [r7, #8]
    539c:	f7ff fee6 	bl	516c <main@@Base+0x2f70>
    53a0:	2800      	cmp	r0, #0
    53a2:	da01      	bge.n	53a8 <main@@Base+0x31ac>
    53a4:	46dd      	mov	sp, fp
    53a6:	e006      	b.n	53b6 <main@@Base+0x31ba>
    53a8:	46dd      	mov	sp, fp
    53aa:	4620      	mov	r0, r4
    53ac:	6939      	ldr	r1, [r7, #16]
    53ae:	4652      	mov	r2, sl
    53b0:	f7ff fe94 	bl	50dc <main@@Base+0x2ee0>
    53b4:	e001      	b.n	53ba <main@@Base+0x31be>
    53b6:	f04f 0a00 	mov.w	sl, #0
    53ba:	6839      	ldr	r1, [r7, #0]
    53bc:	4650      	mov	r0, sl
    53be:	6d7a      	ldr	r2, [r7, #84]	; 0x54
    53c0:	680b      	ldr	r3, [r1, #0]
    53c2:	429a      	cmp	r2, r3
    53c4:	d001      	beq.n	53ca <main@@Base+0x31ce>
    53c6:	f7fc ecca 	blx	1d5c <__stack_chk_fail@plt>
    53ca:	f107 075c 	add.w	r7, r7, #92	; 0x5c
    53ce:	46bd      	mov	sp, r7
    53d0:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
    53d4:	3d18      	subs	r5, #24
    53d6:	0000      	movs	r0, r0
    53d8:	0258      	lsls	r0, r3, #9
    53da:	0000      	movs	r0, r0
    53dc:	2000      	movs	r0, #0
    53de:	f7fc be05 	b.w	1fec <time@plt>
    53e2:	f7fc bcf7 	b.w	1dd4 <memset@plt>
    53e6:	f7fc be0f 	b.w	2008 <memcmp@plt>
    53ea:	f7fc bc8b 	b.w	1d04 <memcpy@plt>
    53ee:	b57f      	push	{r0, r1, r2, r3, r4, r5, r6, lr}
    53f0:	4606      	mov	r6, r0
    53f2:	4b16      	ldr	r3, [pc, #88]	; (544c <main@@Base+0x3250>)
    53f4:	4604      	mov	r4, r0
    53f6:	4a16      	ldr	r2, [pc, #88]	; (5450 <main@@Base+0x3254>)
    53f8:	447b      	add	r3, pc
    53fa:	589d      	ldr	r5, [r3, r2]
    53fc:	682b      	ldr	r3, [r5, #0]
    53fe:	9303      	str	r3, [sp, #12]
    5400:	b1c0      	cbz	r0, 5434 <main@@Base+0x3238>
    5402:	f1a0 040c 	sub.w	r4, r0, #12
    5406:	220c      	movs	r2, #12
    5408:	4668      	mov	r0, sp
    540a:	4621      	mov	r1, r4
    540c:	f7fc ec7c 	blx	1d08 <memcpy@plt+0x4>
    5410:	f8bd 2000 	ldrh.w	r2, [sp]
    5414:	f64d 63ad 	movw	r3, #57005	; 0xdead
    5418:	429a      	cmp	r2, r3
    541a:	d10b      	bne.n	5434 <main@@Base+0x3238>
    541c:	f8bd 2008 	ldrh.w	r2, [sp, #8]
    5420:	f64b 63ef 	movw	r3, #48879	; 0xbeef
    5424:	429a      	cmp	r2, r3
    5426:	d105      	bne.n	5434 <main@@Base+0x3238>
    5428:	9901      	ldr	r1, [sp, #4]
    542a:	4630      	mov	r0, r6
    542c:	2200      	movs	r2, #0
    542e:	460b      	mov	r3, r1
    5430:	f7fc eeae 	blx	2190 <memset_s@plt>
    5434:	9a03      	ldr	r2, [sp, #12]
    5436:	682b      	ldr	r3, [r5, #0]
    5438:	429a      	cmp	r2, r3
    543a:	d001      	beq.n	5440 <main@@Base+0x3244>
    543c:	f7fc ec8e 	blx	1d5c <__stack_chk_fail@plt>
    5440:	4620      	mov	r0, r4
    5442:	b004      	add	sp, #16
    5444:	e8bd 4070 	ldmia.w	sp!, {r4, r5, r6, lr}
    5448:	f7fc bbee 	b.w	1c28 <free@plt>
    544c:	3c04      	subs	r4, #4
    544e:	0000      	movs	r0, r0
    5450:	0258      	lsls	r0, r3, #9
    5452:	0000      	movs	r0, r0
    5454:	b51f      	push	{r0, r1, r2, r3, r4, lr}
    5456:	4b11      	ldr	r3, [pc, #68]	; (549c <main@@Base+0x32a0>)
    5458:	4a11      	ldr	r2, [pc, #68]	; (54a0 <main@@Base+0x32a4>)
    545a:	447b      	add	r3, pc
    545c:	589c      	ldr	r4, [r3, r2]
    545e:	9001      	str	r0, [sp, #4]
    5460:	300c      	adds	r0, #12
    5462:	6823      	ldr	r3, [r4, #0]
    5464:	9303      	str	r3, [sp, #12]
    5466:	f64d 63ad 	movw	r3, #57005	; 0xdead
    546a:	f8ad 3000 	strh.w	r3, [sp]
    546e:	f64b 63ef 	movw	r3, #48879	; 0xbeef
    5472:	f8ad 3008 	strh.w	r3, [sp, #8]
    5476:	f7fc eeb0 	blx	21d8 <malloc@plt>
    547a:	4603      	mov	r3, r0
    547c:	b120      	cbz	r0, 5488 <main@@Base+0x328c>
    547e:	e89d 0007 	ldmia.w	sp, {r0, r1, r2}
    5482:	e883 0007 	stmia.w	r3, {r0, r1, r2}
    5486:	330c      	adds	r3, #12
    5488:	9a03      	ldr	r2, [sp, #12]
    548a:	4618      	mov	r0, r3
    548c:	6823      	ldr	r3, [r4, #0]
    548e:	429a      	cmp	r2, r3
    5490:	d001      	beq.n	5496 <main@@Base+0x329a>
    5492:	f7fc ec64 	blx	1d5c <__stack_chk_fail@plt>
    5496:	b004      	add	sp, #16
    5498:	bd10      	pop	{r4, pc}
    549a:	bf00      	nop
    549c:	3ba2      	subs	r3, #162	; 0xa2
    549e:	0000      	movs	r0, r0
    54a0:	0258      	lsls	r0, r3, #9
    54a2:	0000      	movs	r0, r0
    54a4:	b51f      	push	{r0, r1, r2, r3, r4, lr}
    54a6:	4b18      	ldr	r3, [pc, #96]	; (5508 <main@@Base+0x330c>)
    54a8:	4818      	ldr	r0, [pc, #96]	; (550c <main@@Base+0x3310>)
    54aa:	447b      	add	r3, pc
    54ac:	9300      	str	r3, [sp, #0]
    54ae:	4b18      	ldr	r3, [pc, #96]	; (5510 <main@@Base+0x3314>)
    54b0:	4478      	add	r0, pc
    54b2:	4918      	ldr	r1, [pc, #96]	; (5514 <main@@Base+0x3318>)
    54b4:	447b      	add	r3, pc
    54b6:	4a18      	ldr	r2, [pc, #96]	; (5518 <main@@Base+0x331c>)
    54b8:	9301      	str	r3, [sp, #4]
    54ba:	2300      	movs	r3, #0
    54bc:	9302      	str	r3, [sp, #8]
    54be:	4479      	add	r1, pc
    54c0:	4b16      	ldr	r3, [pc, #88]	; (551c <main@@Base+0x3320>)
    54c2:	447a      	add	r2, pc
    54c4:	4c16      	ldr	r4, [pc, #88]	; (5520 <main@@Base+0x3324>)
    54c6:	447b      	add	r3, pc
    54c8:	447c      	add	r4, pc
    54ca:	9403      	str	r4, [sp, #12]
    54cc:	f7fc eca2 	blx	1e14 <hu_GlobalCtxCreate@plt>
    54d0:	b988      	cbnz	r0, 54f6 <main@@Base+0x32fa>
    54d2:	6820      	ldr	r0, [r4, #0]
    54d4:	f7fc ee2c 	blx	2130 <hu_RegisterSbg56@plt>
    54d8:	b968      	cbnz	r0, 54f6 <main@@Base+0x32fa>
    54da:	6820      	ldr	r0, [r4, #0]
    54dc:	f7fc ee6a 	blx	21b4 <hu_InitSbg56@plt>
    54e0:	f24f 020d 	movw	r2, #61453	; 0xf00d
    54e4:	1c03      	adds	r3, r0, #0
    54e6:	bf18      	it	ne
    54e8:	2301      	movne	r3, #1
    54ea:	4290      	cmp	r0, r2
    54ec:	bf0c      	ite	eq
    54ee:	2000      	moveq	r0, #0
    54f0:	f003 0001 	andne.w	r0, r3, #1
    54f4:	b128      	cbz	r0, 5502 <main@@Base+0x3306>
    54f6:	f7fc eb8c 	blx	1c10 <__get_errno_ptr@plt>
    54fa:	2330      	movs	r3, #48	; 0x30
    54fc:	6003      	str	r3, [r0, #0]
    54fe:	f04f 30ff 	mov.w	r0, #4294967295	; 0xffffffff
    5502:	b004      	add	sp, #16
    5504:	bd10      	pop	{r4, pc}
    5506:	bf00      	nop
    5508:	ff35 ffff 	vminnm.f16	<illegal reg q7.5>, <illegal reg q10.5>, <illegal reg q15.5>
    550c:	ffa1 ffff 			; <UNDEFINED> instruction: 0xffa1ffff
    5510:	ff25 ffff 	vminnm.f32	<illegal reg q7.5>, <illegal reg q10.5>, <illegal reg q15.5>
    5514:	ff2d ffff 	vminnm.f32	<illegal reg q7.5>, <illegal reg q14.5>, <illegal reg q15.5>
    5518:	ff25 ffff 	vminnm.f32	<illegal reg q7.5>, <illegal reg q10.5>, <illegal reg q15.5>
    551c:	ff1d ffff 	vmaxnm.f16	<illegal reg q7.5>, <illegal reg q14.5>, <illegal reg q15.5>
    5520:	3e2c      	subs	r6, #44	; 0x2c
    5522:	0000      	movs	r0, r0
    5524:	e92d 43f7 	stmdb	sp!, {r0, r1, r2, r4, r5, r6, r7, r8, r9, lr}
    5528:	461d      	mov	r5, r3
    552a:	4b1e      	ldr	r3, [pc, #120]	; (55a4 <main@@Base+0x33a8>)
    552c:	4690      	mov	r8, r2
    552e:	4a1e      	ldr	r2, [pc, #120]	; (55a8 <main@@Base+0x33ac>)
    5530:	460f      	mov	r7, r1
    5532:	447b      	add	r3, pc
    5534:	2100      	movs	r1, #0
    5536:	4606      	mov	r6, r0
    5538:	589b      	ldr	r3, [r3, r2]
    553a:	9100      	str	r1, [sp, #0]
    553c:	681a      	ldr	r2, [r3, #0]
    553e:	4699      	mov	r9, r3
    5540:	9201      	str	r2, [sp, #4]
    5542:	682a      	ldr	r2, [r5, #0]
    5544:	2a3f      	cmp	r2, #63	; 0x3f
    5546:	d803      	bhi.n	5550 <main@@Base+0x3354>
    5548:	f7fc eb62 	blx	1c10 <__get_errno_ptr@plt>
    554c:	2322      	movs	r3, #34	; 0x22
    554e:	e00a      	b.n	5566 <main@@Base+0x336a>
    5550:	4c16      	ldr	r4, [pc, #88]	; (55ac <main@@Base+0x33b0>)
    5552:	2040      	movs	r0, #64	; 0x40
    5554:	466a      	mov	r2, sp
    5556:	447c      	add	r4, pc
    5558:	6823      	ldr	r3, [r4, #0]
    555a:	f7fc ecb0 	blx	1ebc <hu_SHA512Begin@plt>
    555e:	b130      	cbz	r0, 556e <main@@Base+0x3372>
    5560:	f7fc eb56 	blx	1c10 <__get_errno_ptr@plt>
    5564:	2330      	movs	r3, #48	; 0x30
    5566:	6003      	str	r3, [r0, #0]
    5568:	f04f 30ff 	mov.w	r0, #4294967295	; 0xffffffff
    556c:	e010      	b.n	5590 <main@@Base+0x3394>
    556e:	9800      	ldr	r0, [sp, #0]
    5570:	4639      	mov	r1, r7
    5572:	4632      	mov	r2, r6
    5574:	6823      	ldr	r3, [r4, #0]
    5576:	f7fc ec42 	blx	1dfc <hu_SHA512Hash@plt>
    557a:	2800      	cmp	r0, #0
    557c:	d1f0      	bne.n	5560 <main@@Base+0x3364>
    557e:	4668      	mov	r0, sp
    5580:	4641      	mov	r1, r8
    5582:	6822      	ldr	r2, [r4, #0]
    5584:	f7fc ec34 	blx	1df0 <hu_SHA512End@plt>
    5588:	2800      	cmp	r0, #0
    558a:	d1e9      	bne.n	5560 <main@@Base+0x3364>
    558c:	2340      	movs	r3, #64	; 0x40
    558e:	602b      	str	r3, [r5, #0]
    5590:	9a01      	ldr	r2, [sp, #4]
    5592:	f8d9 3000 	ldr.w	r3, [r9]
    5596:	429a      	cmp	r2, r3
    5598:	d001      	beq.n	559e <main@@Base+0x33a2>
    559a:	f7fc ebe0 	blx	1d5c <__stack_chk_fail@plt>
    559e:	e8bd 83fe 	ldmia.w	sp!, {r1, r2, r3, r4, r5, r6, r7, r8, r9, pc}
    55a2:	bf00      	nop
    55a4:	3aca      	subs	r2, #202	; 0xca
    55a6:	0000      	movs	r0, r0
    55a8:	0258      	lsls	r0, r3, #9
    55aa:	0000      	movs	r0, r0
    55ac:	3d9e      	subs	r5, #158	; 0x9e
    55ae:	0000      	movs	r0, r0
    55b0:	e92d 43f7 	stmdb	sp!, {r0, r1, r2, r4, r5, r6, r7, r8, r9, lr}
    55b4:	461d      	mov	r5, r3
    55b6:	4b1e      	ldr	r3, [pc, #120]	; (5630 <main@@Base+0x3434>)
    55b8:	4690      	mov	r8, r2
    55ba:	4a1e      	ldr	r2, [pc, #120]	; (5634 <main@@Base+0x3438>)
    55bc:	460f      	mov	r7, r1
    55be:	447b      	add	r3, pc
    55c0:	2100      	movs	r1, #0
    55c2:	4606      	mov	r6, r0
    55c4:	589b      	ldr	r3, [r3, r2]
    55c6:	9100      	str	r1, [sp, #0]
    55c8:	681a      	ldr	r2, [r3, #0]
    55ca:	4699      	mov	r9, r3
    55cc:	9201      	str	r2, [sp, #4]
    55ce:	682a      	ldr	r2, [r5, #0]
    55d0:	2a13      	cmp	r2, #19
    55d2:	d803      	bhi.n	55dc <main@@Base+0x33e0>
    55d4:	f7fc eb1c 	blx	1c10 <__get_errno_ptr@plt>
    55d8:	2322      	movs	r3, #34	; 0x22
    55da:	e00a      	b.n	55f2 <main@@Base+0x33f6>
    55dc:	4c16      	ldr	r4, [pc, #88]	; (5638 <main@@Base+0x343c>)
    55de:	2014      	movs	r0, #20
    55e0:	466a      	mov	r2, sp
    55e2:	447c      	add	r4, pc
    55e4:	6823      	ldr	r3, [r4, #0]
    55e6:	f7fc eb58 	blx	1c98 <hu_SHA1Begin@plt>
    55ea:	b130      	cbz	r0, 55fa <main@@Base+0x33fe>
    55ec:	f7fc eb10 	blx	1c10 <__get_errno_ptr@plt>
    55f0:	2330      	movs	r3, #48	; 0x30
    55f2:	6003      	str	r3, [r0, #0]
    55f4:	f04f 30ff 	mov.w	r0, #4294967295	; 0xffffffff
    55f8:	e010      	b.n	561c <main@@Base+0x3420>
    55fa:	9800      	ldr	r0, [sp, #0]
    55fc:	4639      	mov	r1, r7
    55fe:	4632      	mov	r2, r6
    5600:	6823      	ldr	r3, [r4, #0]
    5602:	f7fc ecc2 	blx	1f88 <hu_SHA1Hash@plt>
    5606:	2800      	cmp	r0, #0
    5608:	d1f0      	bne.n	55ec <main@@Base+0x33f0>
    560a:	4668      	mov	r0, sp
    560c:	4641      	mov	r1, r8
    560e:	6822      	ldr	r2, [r4, #0]
    5610:	f7fc ed82 	blx	2118 <hu_SHA1End@plt>
    5614:	2800      	cmp	r0, #0
    5616:	d1e9      	bne.n	55ec <main@@Base+0x33f0>
    5618:	2314      	movs	r3, #20
    561a:	602b      	str	r3, [r5, #0]
    561c:	9a01      	ldr	r2, [sp, #4]
    561e:	f8d9 3000 	ldr.w	r3, [r9]
    5622:	429a      	cmp	r2, r3
    5624:	d001      	beq.n	562a <main@@Base+0x342e>
    5626:	f7fc eb9a 	blx	1d5c <__stack_chk_fail@plt>
    562a:	e8bd 83fe 	ldmia.w	sp!, {r1, r2, r3, r4, r5, r6, r7, r8, r9, pc}
    562e:	bf00      	nop
    5630:	3a3e      	subs	r2, #62	; 0x3e
    5632:	0000      	movs	r0, r0
    5634:	0258      	lsls	r0, r3, #9
    5636:	0000      	movs	r0, r0
    5638:	3d12      	subs	r5, #18
	...
