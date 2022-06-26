struct lune_bind_entry {
  const char *name;
  const char *proto;
  void *ptr;
};

/*
 * This structure holds any native function you want to share with the Lua code.
 * A light pointer to it is available in lune.entries.
 */
struct lune_bind_entry lune_entries[] = {
  /* Add you own functions here */
  /* e.g { "InitWindow", "void (*)(int, int, const char *)", InitWindow }, */
  { NULL, NULL, NULL },
};
