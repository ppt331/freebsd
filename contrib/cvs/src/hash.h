/* $CVSid: @(#)hash.h 1.23 94/10/07 $	 */

/*
 * Copyright (c) 1992, Brian Berliner and Jeff Polk
 * 
 * You may distribute under the terms of the GNU General Public License as
 * specified in the README file that comes with the CVS 1.4 kit.
 */

/*
 * The number of buckets for the hash table contained in each list.  This
 * should probably be prime.
 */
#define HASHSIZE	151

/*
 * Types of nodes
 */
enum ntype
{
    UNKNOWN, HEADER, ENTRIES, FILES, LIST, RCSNODE,
    RCSVERS, DIRS, UPDATE, LOCK, NDBMNODE, FILEATTR,
    VARIABLE
};
typedef enum ntype Ntype;

struct node
{
    Ntype type;
    struct node *next;
    struct node *prev;
    struct node *hashnext;
    struct node *hashprev;
    char *key;
    char *data;
    void (*delproc) ();
};
typedef struct node Node;

struct list
{
    Node *list;
    Node *hasharray[HASHSIZE];
    struct list *next;
};
typedef struct list List;

List *getlist PROTO((void));
Node *findnode PROTO((List * list, const char *key));
Node *findnode_fn PROTO((List * list, const char *key));
Node *getnode PROTO((void));
int addnode PROTO((List * list, Node * p));
int walklist PROTO((List * list, int (*)(Node *n, void *closure), void *closure));
int list_isempty PROTO ((List *list));
void dellist PROTO((List ** listp));
void delnode PROTO((Node * p));
void freenode PROTO((Node * p));
void sortlist PROTO((List * list, int (*)(const Node *, const Node *)));
