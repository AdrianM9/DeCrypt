# DeCrypt
Various methods of decripting strings by specifying the encrypted string, the key and the method used for encryption.

*(Readme is written in **Romanian language**. A lot of details are explained in the comments which are in **English language**)*


Functii proprii:
  - xor_function: functia a fost creata pentru a nu avea cod duplicat
		si pentru a face mai usor de citit codul. Ea realizeaza xor
		intre doua string-uri.
  - hex_to_binary: functia aeriseste codul pentru task-ul 2. Ea se ocupa
		de conversia din reprezentarea hex a input-ului in binar.
  - base32_to_binary: converteste o valoare din alfabetul base32 in
		valoare aferenta in binar. Functia se apeleaza in cadrul
		task-ului 4 pentru a determina valoarea unui byte din
		string-ul codificat.

Task 1:
  In urma gasirii adresei cheii, se apeleaza functia xor_strings dandu-i
		ca parametii cele doua string-uri. Functia aceasta va apela
		functia proprie xor_operation care va modifica direct string-ul
		din input.

Task 2:
  Se apeleaza functia rolling_xor care va porni procesarea incepand de la
		sfarsitul string-ului, intrucat criptarea a inceput de la
		inceput si exista o dependenta intre caracterele criptate.

Task 3:
	Dupa gasirea adresei cheii, se apeleaza functia hex_to_string pentru a
		transforma string-ul si cheia din valori hex in valori binare,
		iar apoi se realizeaza xor intre string-uri prin intermediul
		functiei xor_function.

Task 4:
	Se realizeaza decodificarea base32. Toate detaliile despre cum au fost
		alese valorile, shiftati registrii, etc. se gasesc in
		comentarii.

Task 5:
	Se apeleaza functia bruteforce_singlebyte_xor care ia fiecare valoare
		din codul ASCII si realizeaza xor cu string-ul dat ca
		parametru pana cand exista cuvantul "force" in rezultat.
		Functia intoarce si cheia care se potriveste decriptarii.

Task 6:
	In urma gasirii adresei cheii, functia decode_vigenere este apelata, ea
		ocupandu-se de decriptarea mesajului. Explicatiile despre
		functionarea acestei metode de decriptare se gasesc in
		comentarii.
