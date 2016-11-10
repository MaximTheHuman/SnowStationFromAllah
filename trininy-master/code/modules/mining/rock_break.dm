/**********************Asteroid**************************/

/turf/simulated/floor/plating/airless/asteroid/rock_break //floor piece
	name = "frozen ground"
	icon = 'icons/turf/landscape.dmi'
	icon_state = "void"
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500
	blocks_air = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T0C-50
	icon_plating = "void"
	dug = 0       //0 = has not yet been dug, 1 = has already been dug

/turf/simulated/floor/plating/airless/rock_break/New()
	var/proper_name = name
	..()
	name = proper_name
//	if(prob(20))
//	spawn(2)
//		updateMineralOverlays()
//	spawn(2)
//	if (src.temperature <= (T0C-25))
//		var/obj/effect/snow/S = locate()
//		if(!S)
//			new /obj/effect/snow(src.loc)
//		else
//			sleep(rand(200,400))
//			new /obj/effect/snow(src.loc)

/turf/simulated/floor/plating/airless/asteroid/rock_break/ex_act(severity)
	switch(severity)
		if(3.0)
			return
		if(2.0)
			if (prob(70))
				src.gets_dug()
		if(1.0)
			src.gets_dug()
	return

/turf/simulated/floor/plating/airless/asteroid/rock_break/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(!W || !user)
		return 0

	if ((istype(W, /obj/item/weapon/shovel)))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug)
			user << "\red This area has already been dug"
			return

		user << "\red You start digging."
		playsound(src.loc, 'sound/effects/rustle1.ogg', 50, 1) //russle sounds sounded better

		sleep(40)
		if ((user.loc == T && user.get_active_hand() == W))
			user << "\blue You dug a hole."
			gets_dug()

	if ((istype(W,/obj/item/weapon/pickaxe/drill)))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug)
			user << "\red This area has already been dug"
			return

		user << "\red You start digging."
		playsound(src.loc, 'sound/effects/rustle1.ogg', 50, 1) //russle sounds sounded better

		sleep(30)
		if ((user.loc == T && user.get_active_hand() == W))
			user << "\blue You dug a hole."
			gets_dug()

	if ((istype(W,/obj/item/weapon/pickaxe/diamonddrill)) || (istype(W,/obj/item/weapon/pickaxe/borgdrill)))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug)
			user << "\red This area has already been dug"
			return

		user << "\red You start digging."
		playsound(src.loc, 'sound/effects/rustle1.ogg', 50, 1) //russle sounds sounded better

		sleep(0)
		if ((user.loc == T && user.get_active_hand() == W))
			user << "\blue You dug a hole."
			gets_dug()

	if(istype(W,/obj/item/weapon/storage/bag/ore))
		var/obj/item/weapon/storage/bag/ore/S = W
		if(S.collection_mode)
			for(var/obj/item/weapon/ore/O in src.contents)
				O.attackby(W,user)
				return

	if (istype(W, /obj/item/stack/rods))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			return
		var/obj/item/stack/rods/R = W
		user << "\blue Constructing support lattice ..."
		playsound(src.loc, 'sound/weapons/Genhit.ogg', 50, 1)
		ReplaceWithLattice()
		R.use(1)
		return

	if (istype(W, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = W
			del(L)
			playsound(src.loc, 'sound/weapons/Genhit.ogg', 50, 1)
			S.build(src)
			S.use(1)
			return
		else
			user << "\red The plating is going to need some support."

	else
		..(W,user)
	return

/turf/simulated/floor/plating/airless/asteroid/rock_break/Entered(atom/movable/M as mob|obj)
	..()
	if(istype(M,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = M
		if(istype(R.module, /obj/item/weapon/robot_module/miner))
			if(istype(R.module_state_1,/obj/item/weapon/storage/bag/ore))
				src.attackby(R.module_state_1,R)
			else if(istype(R.module_state_2,/obj/item/weapon/storage/bag/ore))
				src.attackby(R.module_state_2,R)
			else if(istype(R.module_state_3,/obj/item/weapon/storage/bag/ore))
				src.attackby(R.module_state_3,R)
			else
				return
	if(ticker && ticker.mode)

		// Okay, so let's make it so that people can travel z levels but not nuke disks!
		// if(ticker.mode.name == "nuclear emergency")	return
		if (M.x <= TRANSITIONEDGE || M.x >= (world.maxx - TRANSITIONEDGE - 1) || M.y <= TRANSITIONEDGE || M.y >= (world.maxy - TRANSITIONEDGE - 1))
			if(istype(M, /obj/effect/meteor)||istype(M, /obj/effect/space_dust))
				del(M)
				return

			if(istype(M, /obj/item/weapon/disk/nuclear)) // Don't let nuke disks travel Z levels  ... And moving this shit down here so it only fires when they're actually trying to change z-level.
				del(M) //The disk's Del() proc ensures a new one is created
				return

			var/list/disk_search = M.search_contents_for(/obj/item/weapon/disk/nuclear)
			if(!isemptylist(disk_search))
				if(istype(M, /mob/living))
					var/mob/living/MM = M
					if(MM.client && !MM.stat)
						MM << "\red Something you are carrying is preventing you from leaving. Don't play stupid; you know exactly what it is."
						if(MM.x <= TRANSITIONEDGE)
							MM.inertia_dir = 4
						else if(MM.x >= world.maxx -TRANSITIONEDGE)
							MM.inertia_dir = 8
						else if(MM.y <= TRANSITIONEDGE)
							MM.inertia_dir = 1
						else if(MM.y >= world.maxy -TRANSITIONEDGE)
							MM.inertia_dir = 2
					else
						for(var/obj/item/weapon/disk/nuclear/N in disk_search)
							del(N)//Make the disk respawn it is on a clientless mob or corpse
				else
					for(var/obj/item/weapon/disk/nuclear/N in disk_search)
						del(N)//Make the disk respawn if it is floating on its own
				return


			if(src.x <= TRANSITIONEDGE)
				M.x = world.maxx - TRANSITIONEDGE - 2
				switch(M.z)
					if(1) M.z = 3
					if(2) M.z = 5
					if(3) M.z = 2
					if(4) M.z = 6
					if(5) M.z = 4
					if(6) M.z = 2

			else if (M.x >= (world.maxx - TRANSITIONEDGE - 1))
				M.x = TRANSITIONEDGE + 1
				switch(M.z)
					if(1) M.z = 2
					if(2) M.z = 6
					if(3) M.z = 1
					if(4) M.z = 5
					if(5) M.z = 2
					if(6) M.z = 4

			else if (src.y <= TRANSITIONEDGE)
				M.y = world.maxy - TRANSITIONEDGE -2
				switch(M.z)
					if(1) M.z = 4
					if(2) M.z = 5
					if(3) M.z = 6
					if(4) M.z = 7
					if(5) M.z = 8
					if(6) M.z = 9

			else if (M.y >= (world.maxy - TRANSITIONEDGE - 1))
				M.y = TRANSITIONEDGE + 1
				switch(M.z)
					if(1) M.z = 7
					if(2) M.z = 8
					if(3) M.z = 9
					if(4) M.z = 1
					if(5) M.z = 2
					if(6) M.z = 3

			spawn (0)
				if ((M && M.loc))
					M.loc.Entered(M)