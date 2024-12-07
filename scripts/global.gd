#Direction code for gravity
enum {down=0, right=1, up=2, left=3}
static var dir_mod = 4

static func right_dir(dir) -> int:
	dir += dir_mod + 1
	return dir % dir_mod

static func left_dir(dir) -> int:
	dir += dir_mod - 1
	return dir % dir_mod

#Damage codes
enum {no_attack=0, good_attack=1, bad_attack=2}
enum {no_sword=0, black_sword=1, red_sword=2}
