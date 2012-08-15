include Namespace.Unsupported

let ( |> ) a b = b a

let read t (perms: Perms.t) (path: Store.Path.t) =
	Perms.has perms Perms.CONFIGURE;
	match Store.Path.to_string_list path with
	| [] -> ""
	| "default" :: [] -> ""
	| "domain" :: [] -> ""
	| "maxent" :: [] -> ""
	| "maxwatch" :: [] -> ""
	| "maxtransaction" :: [] -> ""
	| "maxwatchevent" :: [] -> ""
	| "default" :: "maxent" :: [] ->
		string_of_int (!Quota.maxent)
	| "default" :: "maxsize" :: [] ->
		string_of_int (!Quota.maxsize)
	| "default" :: "maxwatch" :: [] ->
		string_of_int (!Quota.maxwatch)
	| "default" :: "maxtransaction" :: [] ->
		string_of_int (!Quota.maxtransaction)
	| "default" :: "maxwatchevent" :: [] ->
		string_of_int (!Quota.maxwatchevent)
	| "domain" :: domid :: [] ->
		let q = t.Transaction.store.Store.quota in
		let domid = int_of_string domid in
		let n = Quota.get q domid in
		string_of_int n
	| "maxent" :: domid :: [] ->
		begin match Quota.get_override Quota.maxent_overrides (int_of_string domid) with
		| Some x -> string_of_int x
		| None -> Store.Path.doesnt_exist path
		end
	| "maxwatch" :: domid :: [] ->
		begin match Quota.get_override Quota.maxwatch_overrides (int_of_string domid) with
		| Some x -> string_of_int x
		| None -> Store.Path.doesnt_exist path
		end
	| "maxtransaction" :: domid :: [] ->
		begin match Quota.get_override Quota.maxtransaction_overrides (int_of_string domid) with
		| Some x -> string_of_int x
		| None -> Store.Path.doesnt_exist path
		end
	| "maxwatchevent" :: domid :: [] ->
		begin match Quota.get_override Quota.maxwatchevent_overrides (int_of_string domid) with
		| Some x -> string_of_int x
		| None -> Store.Path.doesnt_exist path
		end
	| _ -> Store.Path.doesnt_exist path

let exists t perms path = try ignore(read t perms path); true with Store.Path.Doesnt_exist _ -> false

let write t creator perms path value =
	Perms.has perms Perms.CONFIGURE;
	match Store.Path.to_string_list path with
		| "default" :: "maxent" :: [] ->
			Quota.maxent := int_of_string value
		| "default" :: "maxsize" :: [] ->
			Quota.maxsize := int_of_string value
		| "default" :: "maxwatch" :: [] ->
			Quota.maxwatch := int_of_string value
		| "default" :: "maxtransaction" :: [] ->
			Quota.maxtransaction := int_of_string value
		| "default" :: "maxwatchevent" :: [] ->
			Quota.maxwatchevent := int_of_string value
		| "maxent" :: domid :: [] ->
			Quota.set_override Quota.maxent_overrides (int_of_string domid) (Some (int_of_string value))
		| "maxwatch" :: domid :: [] ->
			Quota.set_override Quota.maxwatch_overrides (int_of_string domid) (Some (int_of_string value))
		| "maxtransaction" :: domid :: [] ->
			Quota.set_override Quota.maxtransaction_overrides (int_of_string domid) (Some (int_of_string value))
		| "maxwatchevent" :: domid :: [] ->
			Quota.set_override Quota.maxwatchevent_overrides (int_of_string domid) (Some (int_of_string value))
		| _ -> Store.Path.doesnt_exist path

let list t perms path =
	Perms.has perms Perms.CONFIGURE;
	match Store.Path.to_string_list path with
	| [] -> [ "default"; "domain"; "maxent"; "maxwatch"; "maxtransaction"; "maxwatchevent" ]
	| [ "default" ] -> [ "maxent"; "maxsize"; "maxwatch"; "maxtransaction"; "maxwatchevent" ]
	| [ "domain" ] ->
		let q = t.Transaction.store.Store.quota in
		Quota.list q |> List.map fst |> List.map string_of_int
	| [ "maxent" ] ->
		Quota.list_overrides Quota.maxent_overrides |> List.map fst |> List.map string_of_int
	| [ "maxwatch" ] ->
		Quota.list_overrides Quota.maxwatch_overrides |> List.map fst |> List.map string_of_int
	| [ "maxtransaction" ] ->
		Quota.list_overrides Quota.maxtransaction_overrides |> List.map fst |> List.map string_of_int
	| [ "maxwatchevent" ] ->
		Quota.list_overrides Quota.maxwatchevent_overrides |> List.map fst |> List.map string_of_int
	| _ -> []


let rm t perms path =
	Perms.has perms Perms.CONFIGURE;
	match Store.Path.to_string_list path with
	| "maxent" :: domid :: [] ->
		Quota.set_override Quota.maxent_overrides (int_of_string domid) None
	| "maxwatch" :: domid :: [] ->
		Quota.set_override Quota.maxwatch_overrides (int_of_string domid) None
	| "maxtransaction" :: domid :: [] ->
		Quota.set_override Quota.maxtransaction_overrides (int_of_string domid) None
	| "maxwatchevent" :: domid :: [] ->
		Quota.set_override Quota.maxwatchevent_overrides (int_of_string domid) None
	| _ -> raise Perms.Permission_denied