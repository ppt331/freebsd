#	from: @(#)bsd.prog.mk	5.26 (Berkeley) 6/25/91
#	$Id: bsd.prog.mk,v 1.49 1997/04/23 18:47:42 bde Exp $

.if exists(${.CURDIR}/../Makefile.inc)
.include "${.CURDIR}/../Makefile.inc"
.endif

.SUFFIXES: .out .o .c .cc .cxx .C .y .l .s .S

CFLAGS+=${COPTS} ${DEBUG_FLAGS}
.if defined(DESTDIR)
CFLAGS+= -I${DESTDIR}/usr/include
CXXINCLUDES+= -I${DESTDIR}/usr/include/g++
.endif

.if !defined(DEBUG_FLAGS)
STRIP?=	-s
.endif

.if defined(NOSHARED)
LDFLAGS+= -static
.endif

.if defined(DESTDIR)
LDDESTDIR?=	-L${DESTDIR}${SHLIBDIR} -L${DESTDIR}/usr/lib
# LDDESTDIR+=	-nostdlib
.endif

.if defined(PROG)
.if defined(SRCS)

DPSRCS+= ${SRCS:M*.h}
OBJS+=  ${SRCS:N*.h:R:S/$/.o/g}

${PROG}: ${DPSRCS} ${OBJS}
	${CC} ${CFLAGS} ${LDFLAGS} -o ${.TARGET} ${OBJS} ${LDDESTDIR} ${LDADD}

.else !defined(SRCS)

SRCS=	${PROG}.c

# Always make an intermediate object file because:
# - it saves time rebuilding when only the library has changed
# - the name of the object gets put into the executable symbol table instead of
#   the name of a variable temporary object.
# - it's useful to keep objects around for crunching.
OBJS=	${PROG}.o
${PROG}: ${DPSRCS} ${OBJS}
	${CC} ${CFLAGS} ${LDFLAGS} -o ${.TARGET} ${OBJS} ${LDDESTDIR} ${LDADD}

.endif

.if	!defined(MAN1) && !defined(MAN2) && !defined(MAN3) && \
	!defined(MAN4) && !defined(MAN5) && !defined(MAN6) && \
	!defined(MAN7) && !defined(MAN8) && !defined(NOMAN)
MAN1=	${PROG}.1
.endif
.endif

.MAIN: all
all: objwarn ${PROG} all-man _SUBDIR

.if !target(clean)
clean: _SUBDIR
	rm -f a.out Errs errs mklog ${PROG} ${OBJS} ${CLEANFILES} 
.if defined(CLEANDIRS) && !empty(CLEANDIRS)
	rm -rf ${CLEANDIRS}
.endif
.endif

.if defined(PROG)
_EXTRADEPEND:
	echo ${PROG}: `${CC} -Wl,-f ${CFLAGS} ${LDFLAGS} ${LDDESTDIR} \
	    ${LDADD:S/^/-Wl,/}` >> ${DEPENDFILE}
.endif

.if !target(install)
.if !target(beforeinstall)
beforeinstall:
.endif

realinstall: beforeinstall
.if defined(PROG)
	${INSTALL} ${COPY} ${STRIP} -o ${BINOWN} -g ${BINGRP} -m ${BINMODE} \
	    ${INSTALLFLAGS} ${PROG} ${DESTDIR}${BINDIR}
.endif
.if defined(HIDEGAME)
	(cd ${DESTDIR}/usr/games; rm -f ${PROG}; ln -s dm ${PROG}; \
	    chown games:bin ${PROG})
.endif
.if defined(LINKS) && !empty(LINKS)
	@set ${LINKS}; \
	while test $$# -ge 2; do \
		l=${DESTDIR}$$1; \
		shift; \
		t=${DESTDIR}$$1; \
		shift; \
		${ECHO} $$t -\> $$l; \
		rm -f $$t; \
		ln ${LN_FLAGS} $$l $$t; \
	done; true
.endif

install: afterinstall _SUBDIR
.if !defined(NOMAN)
afterinstall: realinstall maninstall
.else
afterinstall: realinstall
.endif
.endif

DISTRIBUTION?=	bin
.if !target(distribute)
distribute: _SUBDIR
	cd ${.CURDIR} ; $(MAKE) install DESTDIR=${DISTDIR}/${DISTRIBUTION} SHARED=copies
.endif

.if !target(lint)
lint: ${SRCS} _SUBDIR
.if defined(PROG)
	@${LINT} ${LINTFLAGS} ${CFLAGS} ${.ALLSRC} | more 2>&1
.endif
.endif

.if defined(NOTAGS)
tags:
.endif

.if !target(tags)
tags: ${SRCS} _SUBDIR
.if defined(PROG)
	@cd ${.CURDIR} && gtags ${GTAGSFLAGS}
.if defined(HTML)
	@cd ${.CURDIR} && htags ${HTAGSFLAGS}
.endif
.endif
.endif

.if !defined(NOMAN)
.include <bsd.man.mk>
.elif !target(maninstall)
maninstall:
all-man:
.endif

.include <bsd.dep.mk>
.include <bsd.obj.mk>
