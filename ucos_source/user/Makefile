LIB	= user.o

OBJS	= main.o

all:	$(LIB)

$(LIB):	$(OBJS) $(SOBJS)
	$(LD) -r -o $@ $(OBJS) $(SOBJS)

#########################################################################

.depend:	Makefile $(OBJS:.o=.c)
		$(CC) -M $(CFLAGS) $(OBJS:.o=.c) > $@

sinclude .depend

#########################################################################
