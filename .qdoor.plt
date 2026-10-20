
runtime/qnx-shims/qconnDoor.bin:     file format elf32-littlearm


Disassembly of section .plt:

00001b2c <exit@plt-0x14>:
    1b2c:	e52de004 	push	{lr}		; (str lr, [sp, #-4]!)
    1b30:	e59fe004 	ldr	lr, [pc, #4]	; 1b3c <exit@plt-0x4>
    1b34:	e08fe00e 	add	lr, pc, lr
    1b38:	e5bef008 	ldr	pc, [lr, #8]!
    1b3c:	000074c4 	andeq	r7, r0, r4, asr #9

00001b40 <exit@plt>:
    1b40:	e28fc600 	add	ip, pc, #0, 12
    1b44:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1b48:	e5bcf4c4 	ldr	pc, [ip, #1220]!	; 0x4c4

00001b4c <realloc@plt>:
    1b4c:	e28fc600 	add	ip, pc, #0, 12
    1b50:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1b54:	e5bcf4bc 	ldr	pc, [ip, #1212]!	; 0x4bc

00001b58 <memmove@plt>:
    1b58:	e28fc600 	add	ip, pc, #0, 12
    1b5c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1b60:	e5bcf4b4 	ldr	pc, [ip, #1204]!	; 0x4b4

00001b64 <__cxa_finalize@plt>:
    1b64:	e28fc600 	add	ip, pc, #0, 12
    1b68:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1b6c:	e5bcf4ac 	ldr	pc, [ip, #1196]!	; 0x4ac

00001b70 <posix_spawnattr_init@plt>:
    1b70:	e28fc600 	add	ip, pc, #0, 12
    1b74:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1b78:	e5bcf4a4 	ldr	pc, [ip, #1188]!	; 0x4a4

00001b7c <socket@plt>:
    1b7c:	e28fc600 	add	ip, pc, #0, 12
    1b80:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1b84:	e5bcf49c 	ldr	pc, [ip, #1180]!	; 0x49c

00001b88 <pps_decoder_get_int@plt>:
    1b88:	e28fc600 	add	ip, pc, #0, 12
    1b8c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1b90:	e5bcf494 	ldr	pc, [ip, #1172]!	; 0x494

00001b94 <hu_AESDecrypt@plt>:
    1b94:	e28fc600 	add	ip, pc, #0, 12
    1b98:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1b9c:	e5bcf48c 	ldr	pc, [ip, #1164]!	; 0x48c

00001ba0 <pthread_sigmask@plt>:
    1ba0:	e28fc600 	add	ip, pc, #0, 12
    1ba4:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1ba8:	e5bcf484 	ldr	pc, [ip, #1156]!	; 0x484

00001bac <GetRTASGlbCtx@plt>:
    1bac:	e28fc600 	add	ip, pc, #0, 12
    1bb0:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1bb4:	e5bcf47c 	ldr	pc, [ip, #1148]!	; 0x47c

00001bb8 <close@plt>:
    1bb8:	46c04778 			; <UNDEFINED> instruction: 0x46c04778
    1bbc:	e28fc600 	add	ip, pc, #0, 12
    1bc0:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1bc4:	e5bcf470 	ldr	pc, [ip, #1136]!	; 0x470

00001bc8 <__b64_pton@plt>:
    1bc8:	e28fc600 	add	ip, pc, #0, 12
    1bcc:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1bd0:	e5bcf468 	ldr	pc, [ip, #1128]!	; 0x468

00001bd4 <strchr@plt>:
    1bd4:	e28fc600 	add	ip, pc, #0, 12
    1bd8:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1bdc:	e5bcf460 	ldr	pc, [ip, #1120]!	; 0x460

00001be0 <hu_AESBegin@plt>:
    1be0:	e28fc600 	add	ip, pc, #0, 12
    1be4:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1be8:	e5bcf458 	ldr	pc, [ip, #1112]!	; 0x458

00001bec <calloc@plt>:
    1bec:	e28fc600 	add	ip, pc, #0, 12
    1bf0:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1bf4:	e5bcf450 	ldr	pc, [ip, #1104]!	; 0x450

00001bf8 <RTAS_LoadQconnKeyExV2@plt>:
    1bf8:	e28fc600 	add	ip, pc, #0, 12
    1bfc:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1c00:	e5bcf448 	ldr	pc, [ip, #1096]!	; 0x448

00001c04 <stat@plt>:
    1c04:	e28fc600 	add	ip, pc, #0, 12
    1c08:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1c0c:	e5bcf440 	ldr	pc, [ip, #1088]!	; 0x440

00001c10 <__get_errno_ptr@plt>:
    1c10:	e28fc600 	add	ip, pc, #0, 12
    1c14:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1c18:	e5bcf438 	ldr	pc, [ip, #1080]!	; 0x438

00001c1c <strerror@plt>:
    1c1c:	e28fc600 	add	ip, pc, #0, 12
    1c20:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1c24:	e5bcf430 	ldr	pc, [ip, #1072]!	; 0x430

00001c28 <free@plt>:
    1c28:	46c04778 			; <UNDEFINED> instruction: 0x46c04778
    1c2c:	e28fc600 	add	ip, pc, #0, 12
    1c30:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1c34:	e5bcf424 	ldr	pc, [ip, #1060]!	; 0x424

00001c38 <BN_new@plt>:
    1c38:	e28fc600 	add	ip, pc, #0, 12
    1c3c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1c40:	e5bcf41c 	ldr	pc, [ip, #1052]!	; 0x41c

00001c44 <RSA_size@plt>:
    1c44:	e28fc600 	add	ip, pc, #0, 12
    1c48:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1c4c:	e5bcf414 	ldr	pc, [ip, #1044]!	; 0x414

00001c50 <setegid@plt>:
    1c50:	e28fc600 	add	ip, pc, #0, 12
    1c54:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1c58:	e5bcf40c 	ldr	pc, [ip, #1036]!	; 0x40c

00001c5c <posix_spawnattr_setsigmask@plt>:
    1c5c:	e28fc600 	add	ip, pc, #0, 12
    1c60:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1c64:	e5bcf404 	ldr	pc, [ip, #1028]!	; 0x404

00001c68 <strlcat@plt>:
    1c68:	e28fc600 	add	ip, pc, #0, 12
    1c6c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1c70:	e5bcf3fc 	ldr	pc, [ip, #1020]!	; 0x3fc

00001c74 <pps_decoder_init@plt>:
    1c74:	e28fc600 	add	ip, pc, #0, 12
    1c78:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1c7c:	e5bcf3f4 	ldr	pc, [ip, #1012]!	; 0x3f4

00001c80 <pps_encoder_add_int@plt>:
    1c80:	e28fc600 	add	ip, pc, #0, 12
    1c84:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1c88:	e5bcf3ec 	ldr	pc, [ip, #1004]!	; 0x3ec

00001c8c <send@plt>:
    1c8c:	e28fc600 	add	ip, pc, #0, 12
    1c90:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1c94:	e5bcf3e4 	ldr	pc, [ip, #996]!	; 0x3e4

00001c98 <hu_SHA1Begin@plt>:
    1c98:	e28fc600 	add	ip, pc, #0, 12
    1c9c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1ca0:	e5bcf3dc 	ldr	pc, [ip, #988]!	; 0x3dc

00001ca4 <posix_spawnattr_setxflags@plt>:
    1ca4:	e28fc600 	add	ip, pc, #0, 12
    1ca8:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1cac:	e5bcf3d4 	ldr	pc, [ip, #980]!	; 0x3d4

00001cb0 <unlink@plt>:
    1cb0:	e28fc600 	add	ip, pc, #0, 12
    1cb4:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1cb8:	e5bcf3cc 	ldr	pc, [ip, #972]!	; 0x3cc

00001cbc <sched_getscheduler@plt>:
    1cbc:	e28fc600 	add	ip, pc, #0, 12
    1cc0:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1cc4:	e5bcf3c4 	ldr	pc, [ip, #964]!	; 0x3c4

00001cc8 <seteuid@plt>:
    1cc8:	e28fc600 	add	ip, pc, #0, 12
    1ccc:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1cd0:	e5bcf3bc 	ldr	pc, [ip, #956]!	; 0x3bc

00001cd4 <sysconf@plt>:
    1cd4:	e28fc600 	add	ip, pc, #0, 12
    1cd8:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1cdc:	e5bcf3b4 	ldr	pc, [ip, #948]!	; 0x3b4

00001ce0 <waitpid@plt>:
    1ce0:	e28fc600 	add	ip, pc, #0, 12
    1ce4:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1ce8:	e5bcf3ac 	ldr	pc, [ip, #940]!	; 0x3ac

00001cec <BN_bin2bn@plt>:
    1cec:	e28fc600 	add	ip, pc, #0, 12
    1cf0:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1cf4:	e5bcf3a4 	ldr	pc, [ip, #932]!	; 0x3a4

00001cf8 <RSA_free@plt>:
    1cf8:	e28fc600 	add	ip, pc, #0, 12
    1cfc:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1d00:	e5bcf39c 	ldr	pc, [ip, #924]!	; 0x39c

00001d04 <memcpy@plt>:
    1d04:	46c04778 			; <UNDEFINED> instruction: 0x46c04778
    1d08:	e28fc600 	add	ip, pc, #0, 12
    1d0c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1d10:	e5bcf390 	ldr	pc, [ip, #912]!	; 0x390

00001d14 <pps_decoder_push@plt>:
    1d14:	e28fc600 	add	ip, pc, #0, 12
    1d18:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1d1c:	e5bcf388 	ldr	pc, [ip, #904]!	; 0x388

00001d20 <posix_spawnattr_setcred@plt>:
    1d20:	e28fc600 	add	ip, pc, #0, 12
    1d24:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1d28:	e5bcf380 	ldr	pc, [ip, #896]!	; 0x380

00001d2c <_init_libc@plt>:
    1d2c:	e28fc600 	add	ip, pc, #0, 12
    1d30:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1d34:	e5bcf378 	ldr	pc, [ip, #888]!	; 0x378

00001d38 <listen@plt>:
    1d38:	e28fc600 	add	ip, pc, #0, 12
    1d3c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1d40:	e5bcf370 	ldr	pc, [ip, #880]!	; 0x370

00001d44 <fork@plt>:
    1d44:	e28fc600 	add	ip, pc, #0, 12
    1d48:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1d4c:	e5bcf368 	ldr	pc, [ip, #872]!	; 0x368

00001d50 <setuid@plt>:
    1d50:	e28fc600 	add	ip, pc, #0, 12
    1d54:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1d58:	e5bcf360 	ldr	pc, [ip, #864]!	; 0x360

00001d5c <__stack_chk_fail@plt>:
    1d5c:	e28fc600 	add	ip, pc, #0, 12
    1d60:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1d64:	e5bcf358 	ldr	pc, [ip, #856]!	; 0x358

00001d68 <pps_decoder_parse@plt>:
    1d68:	e28fc600 	add	ip, pc, #0, 12
    1d6c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1d70:	e5bcf350 	ldr	pc, [ip, #848]!	; 0x350

00001d74 <lstat@plt>:
    1d74:	e28fc600 	add	ip, pc, #0, 12
    1d78:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1d7c:	e5bcf348 	ldr	pc, [ip, #840]!	; 0x348

00001d80 <fstat@plt>:
    1d80:	e28fc600 	add	ip, pc, #0, 12
    1d84:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1d88:	e5bcf340 	ldr	pc, [ip, #832]!	; 0x340

00001d8c <fileno@plt>:
    1d8c:	e28fc600 	add	ip, pc, #0, 12
    1d90:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1d94:	e5bcf338 	ldr	pc, [ip, #824]!	; 0x338

00001d98 <posix_spawn@plt>:
    1d98:	e28fc600 	add	ip, pc, #0, 12
    1d9c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1da0:	e5bcf330 	ldr	pc, [ip, #816]!	; 0x330

00001da4 <slogf@plt>:
    1da4:	e28fc600 	add	ip, pc, #0, 12
    1da8:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1dac:	e5bcf328 	ldr	pc, [ip, #808]!	; 0x328

00001db0 <pps_encoder_start_object@plt>:
    1db0:	e28fc600 	add	ip, pc, #0, 12
    1db4:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1db8:	e5bcf320 	ldr	pc, [ip, #800]!	; 0x320

00001dbc <_init_array@plt>:
    1dbc:	e28fc600 	add	ip, pc, #0, 12
    1dc0:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1dc4:	e5bcf318 	ldr	pc, [ip, #792]!	; 0x318

00001dc8 <InitEncryptionChallenge@plt>:
    1dc8:	e28fc600 	add	ip, pc, #0, 12
    1dcc:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1dd0:	e5bcf310 	ldr	pc, [ip, #784]!	; 0x310

00001dd4 <memset@plt>:
    1dd4:	46c04778 			; <UNDEFINED> instruction: 0x46c04778
    1dd8:	e28fc600 	add	ip, pc, #0, 12
    1ddc:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1de0:	e5bcf304 	ldr	pc, [ip, #772]!	; 0x304

00001de4 <sigaction@plt>:
    1de4:	e28fc600 	add	ip, pc, #0, 12
    1de8:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1dec:	e5bcf2fc 	ldr	pc, [ip, #764]!	; 0x2fc

00001df0 <hu_SHA512End@plt>:
    1df0:	e28fc600 	add	ip, pc, #0, 12
    1df4:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1df8:	e5bcf2f4 	ldr	pc, [ip, #756]!	; 0x2f4

00001dfc <hu_SHA512Hash@plt>:
    1dfc:	e28fc600 	add	ip, pc, #0, 12
    1e00:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1e04:	e5bcf2ec 	ldr	pc, [ip, #748]!	; 0x2ec

00001e08 <VerifyEncryptionChallenge@plt>:
    1e08:	e28fc600 	add	ip, pc, #0, 12
    1e0c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1e10:	e5bcf2e4 	ldr	pc, [ip, #740]!	; 0x2e4

00001e14 <hu_GlobalCtxCreate@plt>:
    1e14:	e28fc600 	add	ip, pc, #0, 12
    1e18:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1e1c:	e5bcf2dc 	ldr	pc, [ip, #732]!	; 0x2dc

00001e20 <bind@plt>:
    1e20:	e28fc600 	add	ip, pc, #0, 12
    1e24:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1e28:	e5bcf2d4 	ldr	pc, [ip, #724]!	; 0x2d4

00001e2c <getsockname@plt>:
    1e2c:	e28fc600 	add	ip, pc, #0, 12
    1e30:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1e34:	e5bcf2cc 	ldr	pc, [ip, #716]!	; 0x2cc

00001e38 <_fini_array@plt>:
    1e38:	e28fc600 	add	ip, pc, #0, 12
    1e3c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1e40:	e5bcf2c4 	ldr	pc, [ip, #708]!	; 0x2c4

00001e44 <SignalKill_r@plt>:
    1e44:	e28fc600 	add	ip, pc, #0, 12
    1e48:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1e4c:	e5bcf2bc 	ldr	pc, [ip, #700]!	; 0x2bc

00001e50 <read@plt>:
    1e50:	e28fc600 	add	ip, pc, #0, 12
    1e54:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1e58:	e5bcf2b4 	ldr	pc, [ip, #692]!	; 0x2b4

00001e5c <pps_encoder_cleanup@plt>:
    1e5c:	e28fc600 	add	ip, pc, #0, 12
    1e60:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1e64:	e5bcf2ac 	ldr	pc, [ip, #684]!	; 0x2ac

00001e68 <pps_encoder_buffer@plt>:
    1e68:	e28fc600 	add	ip, pc, #0, 12
    1e6c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1e70:	e5bcf2a4 	ldr	pc, [ip, #676]!	; 0x2a4

00001e74 <freeifaddrs@plt>:
    1e74:	e28fc600 	add	ip, pc, #0, 12
    1e78:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1e7c:	e5bcf29c 	ldr	pc, [ip, #668]!	; 0x29c

00001e80 <geteuid@plt>:
    1e80:	e28fc600 	add	ip, pc, #0, 12
    1e84:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1e88:	e5bcf294 	ldr	pc, [ip, #660]!	; 0x294

00001e8c <execl@plt>:
    1e8c:	e28fc600 	add	ip, pc, #0, 12
    1e90:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1e94:	e5bcf28c 	ldr	pc, [ip, #652]!	; 0x28c

00001e98 <atoi@plt>:
    1e98:	e28fc600 	add	ip, pc, #0, 12
    1e9c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1ea0:	e5bcf284 	ldr	pc, [ip, #644]!	; 0x284

00001ea4 <posix_spawnattr_setschedparam@plt>:
    1ea4:	e28fc600 	add	ip, pc, #0, 12
    1ea8:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1eac:	e5bcf27c 	ldr	pc, [ip, #636]!	; 0x27c

00001eb0 <pps_encoder_delete_attribute@plt>:
    1eb0:	e28fc600 	add	ip, pc, #0, 12
    1eb4:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1eb8:	e5bcf274 	ldr	pc, [ip, #628]!	; 0x274

00001ebc <hu_SHA512Begin@plt>:
    1ebc:	e28fc600 	add	ip, pc, #0, 12
    1ec0:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1ec4:	e5bcf26c 	ldr	pc, [ip, #620]!	; 0x26c

00001ec8 <initgroups@plt>:
    1ec8:	e28fc600 	add	ip, pc, #0, 12
    1ecc:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1ed0:	e5bcf264 	ldr	pc, [ip, #612]!	; 0x264

00001ed4 <fwrite@plt>:
    1ed4:	e28fc600 	add	ip, pc, #0, 12
    1ed8:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1edc:	e5bcf25c 	ldr	pc, [ip, #604]!	; 0x25c

00001ee0 <pps_decoder_type@plt>:
    1ee0:	e28fc600 	add	ip, pc, #0, 12
    1ee4:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1ee8:	e5bcf254 	ldr	pc, [ip, #596]!	; 0x254

00001eec <vsnprintf@plt>:
    1eec:	e28fc600 	add	ip, pc, #0, 12
    1ef0:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1ef4:	e5bcf24c 	ldr	pc, [ip, #588]!	; 0x24c

00001ef8 <strlcpy@plt>:
    1ef8:	e28fc600 	add	ip, pc, #0, 12
    1efc:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1f00:	e5bcf244 	ldr	pc, [ip, #580]!	; 0x244

00001f04 <fopen@plt>:
    1f04:	e28fc600 	add	ip, pc, #0, 12
    1f08:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1f0c:	e5bcf23c 	ldr	pc, [ip, #572]!	; 0x23c

00001f10 <__deregister_frame_info@plt>:
    1f10:	e28fc600 	add	ip, pc, #0, 12
    1f14:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1f18:	e5bcf234 	ldr	pc, [ip, #564]!	; 0x234

00001f1c <mkdir@plt>:
    1f1c:	e28fc600 	add	ip, pc, #0, 12
    1f20:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1f24:	e5bcf22c 	ldr	pc, [ip, #556]!	; 0x22c

00001f28 <sigaddset@plt>:
    1f28:	e28fc600 	add	ip, pc, #0, 12
    1f2c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1f30:	e5bcf224 	ldr	pc, [ip, #548]!	; 0x224

00001f34 <RSA_new@plt>:
    1f34:	e28fc600 	add	ip, pc, #0, 12
    1f38:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1f3c:	e5bcf21c 	ldr	pc, [ip, #540]!	; 0x21c

00001f40 <__register_frame_info@plt>:
    1f40:	e28fc600 	add	ip, pc, #0, 12
    1f44:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1f48:	e5bcf214 	ldr	pc, [ip, #532]!	; 0x214

00001f4c <procmgr_ability@plt>:
    1f4c:	e28fc600 	add	ip, pc, #0, 12
    1f50:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1f54:	e5bcf20c 	ldr	pc, [ip, #524]!	; 0x20c

00001f58 <pps_encoder_add_string@plt>:
    1f58:	e28fc600 	add	ip, pc, #0, 12
    1f5c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1f60:	e5bcf204 	ldr	pc, [ip, #516]!	; 0x204

00001f64 <pps_decoder_get_bool@plt>:
    1f64:	e28fc600 	add	ip, pc, #0, 12
    1f68:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1f6c:	e5bcf1fc 	ldr	pc, [ip, #508]!	; 0x1fc

00001f70 <recv@plt>:
    1f70:	e28fc600 	add	ip, pc, #0, 12
    1f74:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1f78:	e5bcf1f4 	ldr	pc, [ip, #500]!	; 0x1f4

00001f7c <posix_spawnattr_destroy@plt>:
    1f7c:	e28fc600 	add	ip, pc, #0, 12
    1f80:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1f84:	e5bcf1ec 	ldr	pc, [ip, #492]!	; 0x1ec

00001f88 <hu_SHA1Hash@plt>:
    1f88:	e28fc600 	add	ip, pc, #0, 12
    1f8c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1f90:	e5bcf1e4 	ldr	pc, [ip, #484]!	; 0x1e4

00001f94 <setsockopt@plt>:
    1f94:	e28fc600 	add	ip, pc, #0, 12
    1f98:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1f9c:	e5bcf1dc 	ldr	pc, [ip, #476]!	; 0x1dc

00001fa0 <write@plt>:
    1fa0:	e28fc600 	add	ip, pc, #0, 12
    1fa4:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1fa8:	e5bcf1d4 	ldr	pc, [ip, #468]!	; 0x1d4

00001fac <setgroups@plt>:
    1fac:	e28fc600 	add	ip, pc, #0, 12
    1fb0:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1fb4:	e5bcf1cc 	ldr	pc, [ip, #460]!	; 0x1cc

00001fb8 <pps_encoder_length@plt>:
    1fb8:	e28fc600 	add	ip, pc, #0, 12
    1fbc:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1fc0:	e5bcf1c4 	ldr	pc, [ip, #452]!	; 0x1c4

00001fc4 <_preinit_array@plt>:
    1fc4:	e28fc600 	add	ip, pc, #0, 12
    1fc8:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1fcc:	e5bcf1bc 	ldr	pc, [ip, #444]!	; 0x1bc

00001fd0 <DisposeEncryptionChallengeKeys@plt>:
    1fd0:	46c04778 			; <UNDEFINED> instruction: 0x46c04778
    1fd4:	e28fc600 	add	ip, pc, #0, 12
    1fd8:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1fdc:	e5bcf1b0 	ldr	pc, [ip, #432]!	; 0x1b0

00001fe0 <pps_decoder_initialize@plt>:
    1fe0:	e28fc600 	add	ip, pc, #0, 12
    1fe4:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1fe8:	e5bcf1a8 	ldr	pc, [ip, #424]!	; 0x1a8

00001fec <time@plt>:
    1fec:	46c04778 			; <UNDEFINED> instruction: 0x46c04778
    1ff0:	e28fc600 	add	ip, pc, #0, 12
    1ff4:	e28cca07 	add	ip, ip, #28672	; 0x7000
    1ff8:	e5bcf19c 	ldr	pc, [ip, #412]!	; 0x19c

00001ffc <strncpy@plt>:
    1ffc:	e28fc600 	add	ip, pc, #0, 12
    2000:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2004:	e5bcf194 	ldr	pc, [ip, #404]!	; 0x194

00002008 <memcmp@plt>:
    2008:	46c04778 			; <UNDEFINED> instruction: 0x46c04778
    200c:	e28fc600 	add	ip, pc, #0, 12
    2010:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2014:	e5bcf188 	ldr	pc, [ip, #392]!	; 0x188

00002018 <fclose@plt>:
    2018:	e28fc600 	add	ip, pc, #0, 12
    201c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2020:	e5bcf180 	ldr	pc, [ip, #384]!	; 0x180

00002024 <strdup@plt>:
    2024:	e28fc600 	add	ip, pc, #0, 12
    2028:	e28cca07 	add	ip, ip, #28672	; 0x7000
    202c:	e5bcf178 	ldr	pc, [ip, #376]!	; 0x178

00002030 <GetEncryptionChallengeEx@plt>:
    2030:	e28fc600 	add	ip, pc, #0, 12
    2034:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2038:	e5bcf170 	ldr	pc, [ip, #368]!	; 0x170

0000203c <inet_ntop@plt>:
    203c:	e28fc600 	add	ip, pc, #0, 12
    2040:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2044:	e5bcf168 	ldr	pc, [ip, #360]!	; 0x168

00002048 <fchmod@plt>:
    2048:	e28fc600 	add	ip, pc, #0, 12
    204c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2050:	e5bcf160 	ldr	pc, [ip, #352]!	; 0x160

00002054 <__aeabi_uidivmod@plt>:
    2054:	e28fc600 	add	ip, pc, #0, 12
    2058:	e28cca07 	add	ip, ip, #28672	; 0x7000
    205c:	e5bcf158 	ldr	pc, [ip, #344]!	; 0x158

00002060 <DisposeEncryptionChallenge@plt>:
    2060:	e28fc600 	add	ip, pc, #0, 12
    2064:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2068:	e5bcf150 	ldr	pc, [ip, #336]!	; 0x150

0000206c <sigemptyset@plt>:
    206c:	e28fc600 	add	ip, pc, #0, 12
    2070:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2074:	e5bcf148 	ldr	pc, [ip, #328]!	; 0x148

00002078 <accept@plt>:
    2078:	e28fc600 	add	ip, pc, #0, 12
    207c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2080:	e5bcf140 	ldr	pc, [ip, #320]!	; 0x140

00002084 <pps_encoder_add_bool@plt>:
    2084:	e28fc600 	add	ip, pc, #0, 12
    2088:	e28cca07 	add	ip, ip, #28672	; 0x7000
    208c:	e5bcf138 	ldr	pc, [ip, #312]!	; 0x138

00002090 <getpwnam@plt>:
    2090:	e28fc600 	add	ip, pc, #0, 12
    2094:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2098:	e5bcf130 	ldr	pc, [ip, #304]!	; 0x130

0000209c <pps_decoder_pop@plt>:
    209c:	e28fc600 	add	ip, pc, #0, 12
    20a0:	e28cca07 	add	ip, ip, #28672	; 0x7000
    20a4:	e5bcf128 	ldr	pc, [ip, #296]!	; 0x128

000020a8 <pps_encoder_end_object@plt>:
    20a8:	e28fc600 	add	ip, pc, #0, 12
    20ac:	e28cca07 	add	ip, ip, #28672	; 0x7000
    20b0:	e5bcf120 	ldr	pc, [ip, #288]!	; 0x120

000020b4 <getgroups@plt>:
    20b4:	e28fc600 	add	ip, pc, #0, 12
    20b8:	e28cca07 	add	ip, ip, #28672	; 0x7000
    20bc:	e5bcf118 	ldr	pc, [ip, #280]!	; 0x118

000020c0 <getopt@plt>:
    20c0:	e28fc600 	add	ip, pc, #0, 12
    20c4:	e28cca07 	add	ip, ip, #28672	; 0x7000
    20c8:	e5bcf110 	ldr	pc, [ip, #272]!	; 0x110

000020cc <pps_decoder_cleanup@plt>:
    20cc:	e28fc600 	add	ip, pc, #0, 12
    20d0:	e28cca07 	add	ip, ip, #28672	; 0x7000
    20d4:	e5bcf108 	ldr	pc, [ip, #264]!	; 0x108

000020d8 <open@plt>:
    20d8:	e28fc600 	add	ip, pc, #0, 12
    20dc:	e28cca07 	add	ip, ip, #28672	; 0x7000
    20e0:	e5bcf100 	ldr	pc, [ip, #256]!	; 0x100

000020e4 <pps_decoder_get_string@plt>:
    20e4:	e28fc600 	add	ip, pc, #0, 12
    20e8:	e28cca07 	add	ip, ip, #28672	; 0x7000
    20ec:	e5bcf0f8 	ldr	pc, [ip, #248]!	; 0xf8

000020f0 <getpwuid@plt>:
    20f0:	e28fc600 	add	ip, pc, #0, 12
    20f4:	e28cca07 	add	ip, ip, #28672	; 0x7000
    20f8:	e5bcf0f0 	ldr	pc, [ip, #240]!	; 0xf0

000020fc <sprintf@plt>:
    20fc:	e28fc600 	add	ip, pc, #0, 12
    2100:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2104:	e5bcf0e8 	ldr	pc, [ip, #232]!	; 0xe8

00002108 <sleep@plt>:
    2108:	46c04778 			; <UNDEFINED> instruction: 0x46c04778
    210c:	e28fc600 	add	ip, pc, #0, 12
    2110:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2114:	e5bcf0dc 	ldr	pc, [ip, #220]!	; 0xdc

00002118 <hu_SHA1End@plt>:
    2118:	e28fc600 	add	ip, pc, #0, 12
    211c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2120:	e5bcf0d4 	ldr	pc, [ip, #212]!	; 0xd4

00002124 <signal@plt>:
    2124:	e28fc600 	add	ip, pc, #0, 12
    2128:	e28cca07 	add	ip, ip, #28672	; 0x7000
    212c:	e5bcf0cc 	ldr	pc, [ip, #204]!	; 0xcc

00002130 <hu_RegisterSbg56@plt>:
    2130:	e28fc600 	add	ip, pc, #0, 12
    2134:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2138:	e5bcf0c4 	ldr	pc, [ip, #196]!	; 0xc4

0000213c <select@plt>:
    213c:	e28fc600 	add	ip, pc, #0, 12
    2140:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2144:	e5bcf0bc 	ldr	pc, [ip, #188]!	; 0xbc

00002148 <strlen@plt>:
    2148:	e28fc600 	add	ip, pc, #0, 12
    214c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2150:	e5bcf0b4 	ldr	pc, [ip, #180]!	; 0xb4

00002154 <setgid@plt>:
    2154:	e28fc600 	add	ip, pc, #0, 12
    2158:	e28cca07 	add	ip, ip, #28672	; 0x7000
    215c:	e5bcf0ac 	ldr	pc, [ip, #172]!	; 0xac

00002160 <strtol@plt>:
    2160:	e28fc600 	add	ip, pc, #0, 12
    2164:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2168:	e5bcf0a4 	ldr	pc, [ip, #164]!	; 0xa4

0000216c <sched_setscheduler@plt>:
    216c:	e28fc600 	add	ip, pc, #0, 12
    2170:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2174:	e5bcf09c 	ldr	pc, [ip, #156]!	; 0x9c

00002178 <posix_spawnattr_setpgroup@plt>:
    2178:	e28fc600 	add	ip, pc, #0, 12
    217c:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2180:	e5bcf094 	ldr	pc, [ip, #148]!	; 0x94

00002184 <getifaddrs@plt>:
    2184:	e28fc600 	add	ip, pc, #0, 12
    2188:	e28cca07 	add	ip, ip, #28672	; 0x7000
    218c:	e5bcf08c 	ldr	pc, [ip, #140]!	; 0x8c

00002190 <memset_s@plt>:
    2190:	e28fc600 	add	ip, pc, #0, 12
    2194:	e28cca07 	add	ip, ip, #28672	; 0x7000
    2198:	e5bcf084 	ldr	pc, [ip, #132]!	; 0x84

0000219c <getgrouplist@plt>:
    219c:	e28fc600 	add	ip, pc, #0, 12
    21a0:	e28cca07 	add	ip, ip, #28672	; 0x7000
    21a4:	e5bcf07c 	ldr	pc, [ip, #124]!	; 0x7c

000021a8 <sched_getparam@plt>:
    21a8:	e28fc600 	add	ip, pc, #0, 12
    21ac:	e28cca07 	add	ip, ip, #28672	; 0x7000
    21b0:	e5bcf074 	ldr	pc, [ip, #116]!	; 0x74

000021b4 <hu_InitSbg56@plt>:
    21b4:	e28fc600 	add	ip, pc, #0, 12
    21b8:	e28cca07 	add	ip, ip, #28672	; 0x7000
    21bc:	e5bcf06c 	ldr	pc, [ip, #108]!	; 0x6c

000021c0 <pps_encoder_initialize@plt>:
    21c0:	e28fc600 	add	ip, pc, #0, 12
    21c4:	e28cca07 	add	ip, ip, #28672	; 0x7000
    21c8:	e5bcf064 	ldr	pc, [ip, #100]!	; 0x64

000021cc <hu_AESEnd@plt>:
    21cc:	e28fc600 	add	ip, pc, #0, 12
    21d0:	e28cca07 	add	ip, ip, #28672	; 0x7000
    21d4:	e5bcf05c 	ldr	pc, [ip, #92]!	; 0x5c

000021d8 <malloc@plt>:
    21d8:	e28fc600 	add	ip, pc, #0, 12
    21dc:	e28cca07 	add	ip, ip, #28672	; 0x7000
    21e0:	e5bcf054 	ldr	pc, [ip, #84]!	; 0x54

000021e4 <strcmp@plt>:
    21e4:	e28fc600 	add	ip, pc, #0, 12
    21e8:	e28cca07 	add	ip, ip, #28672	; 0x7000
    21ec:	e5bcf04c 	ldr	pc, [ip, #76]!	; 0x4c

000021f0 <chmod@plt>:
    21f0:	e28fc600 	add	ip, pc, #0, 12
    21f4:	e28cca07 	add	ip, ip, #28672	; 0x7000
    21f8:	e5bcf044 	ldr	pc, [ip, #68]!	; 0x44
