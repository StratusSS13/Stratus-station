/obj/item/weapon/storage/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon_state ="bible"
	throw_speed = 1
	throw_range = 5
	w_class = 3
	burn_state = FLAMMABLE
	var/mob/affecting = null
	var/deity_name = "Christ"

/obj/item/weapon/storage/bible/booze
	name = "bible"
	desc = "To be applied to the head repeatedly."
	icon_state ="bible"

/obj/item/weapon/storage/bible/booze/New()
	..()
	new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/weapon/spacecash(src)
	new /obj/item/weapon/spacecash(src)
	new /obj/item/weapon/spacecash(src)
//BS12 EDIT
 // All cult functionality moved to Null Rod
/obj/item/weapon/storage/bible/proc/bless(mob/living/carbon/M as mob)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/heal_amt = 10
		for(var/obj/item/organ/external/affecting in H.organs)
			if(affecting.heal_damage(heal_amt, heal_amt))
				H.UpdateDamageIcon()
	return

/obj/item/weapon/storage/bible/attack(mob/living/M as mob, mob/living/user as mob)

	var/chaplain = 0
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		chaplain = 1


	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")
	log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	if(!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		to_chat(user, "\red You don't have the dexterity to do this!")
		return
	if(!chaplain)
		to_chat(user, "\red The book sizzles in your hands.")
		user.take_organ_damage(0,10)
		return

	if((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "\red The [src] slips out of your hand and hits your head.")
		user.take_organ_damage(10)
		user.Paralyse(20)
		return

//	if(..() == BLOCKED)
//		return

	if(M.stat !=2)
		/*if((M.mind in ticker.mode.cult) && (prob(20)))
			to_chat(M, "\red The power of [src.deity_name] clears your mind of heresy!")
			to_chat(user, "\red You see how [M]'s eyes become clear, the cult no longer holds control over him!")
			ticker.mode.remove_cultist(M.mind)*/
		if((istype(M, /mob/living/carbon/human) && prob(60)))
			bless(M)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] heals [] with the power of [src.deity_name]!</span>", user, M), 1)
			to_chat(M, "\red May the power of [src.deity_name] compel you to be healed!")
			playsound(src.loc, "punch", 25, 1, -1)
		else
			if(ishuman(M) && !istype(M:head, /obj/item/clothing/head/helmet))
				M.adjustBrainLoss(10)
				to_chat(M, "\red You feel dumber.")
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] beats [] over the head with []!</span>", user, M, src), 1)
			playsound(src.loc, "punch", 25, 1, -1)
	else if(M.stat == 2)
		for(var/mob/O in viewers(M, null))
			O.show_message(text("<span class='danger'>[] smacks []'s lifeless corpse with [].</span>", user, M, src), 1)
		playsound(src.loc, "punch", 25, 1, -1)
	return

/obj/item/weapon/storage/bible/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity)
		return
	if(istype(A, /turf/simulated/floor))
		to_chat(user, "<span class='notice'>You hit the floor with the bible.</span>")
		if(user.mind && (user.mind.assigned_role == "Chaplain"))
			call(/obj/effect/rune/proc/revealrunes)(src)
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		if(A.reagents && A.reagents.has_reagent("water")) //blesses all the water in the holder
			to_chat(user, "<span class='notice'>You bless [A].</span>")
			var/water2holy = A.reagents.get_reagent_amount("water")
			A.reagents.del_reagent("water")
			A.reagents.add_reagent("holywater",water2holy)
		if(A.reagents && A.reagents.has_reagent("unholywater")) //yeah yeah, copy pasted code - sue me
			to_chat(user, "<span class='notice'>You purify [A].</span>")
			var/unholy2clean = A.reagents.get_reagent_amount("unholywater")
			A.reagents.del_reagent("unholywater")
			A.reagents.add_reagent("holywater",unholy2clean)

/obj/item/weapon/storage/bible/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	playsound(src.loc, "rustle", 50, 1, -5)
	..()
