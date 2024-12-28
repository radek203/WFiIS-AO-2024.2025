clear; clc; close all;

imc = imread('kaczki.jpg');
imc = double(imc) / 255;

figure;
subplot(2,2,1);
imshow(imc);
title("Oryginal");

im = rgb2gray(imc);

subplot(2,2,2);
imshow(im);
title("Odcienie szarosci");

t = graythresh(im);
% imbinarize(im, t);
bim = ~imbinarize(im, t);
subplot(2,2,3);
imshow(bim);
title("Binaryzacja");

% dbim = imerode(bim, ones(11));
% dbim = ~dbim;
cbim = imclose(bim, ones(11));
subplot(2,2,4);
imshow(cbim);
title("imclose - ones(11)");

saveas(gcf, 'zdj1.jpg');

% mbim = bwmorph(bim, 'erode'); % nie mamy takiej kontroli lepiej imerode
% subplot(2,2,4);
% imshow(mbim);

figure;
mbim = bwmorph(cbim, 'remove'); % zostawia krawedzie - tak jak filtr krawedziowy
subplot(2,2,1);
imshow(mbim);
title("bwmorph - remove");

mbim = bwmorph(cbim, 'skel', Inf); % mozna podac ilosc iteracji, jak Inf to tak dlugo jak bedzie sie cos zmieniac
subplot(2,2,2); % skel - otrzymujemy szkielet obiektu, piksele ktore sa w odleglosci takiej samej od 2 roznych krawedzi
imshow(mbim);
title("bwmorph - skel, inf");

ebim = bwmorph(mbim, 'endpoints'); % punkty koncowe linii
subplot(2,2,3);
imshow(ebim);
title("bwmorph - endpoints");

bbim = bwmorph(mbim, 'branchpoints'); % punkty skrzyzowan
subplot(2,2,4);
imshow(bbim);
title("bwmorph - branchpoints");

saveas(gcf, 'zdj2.jpg');

% na podstawie tego mozna odbudowac szkielet

% [y,x]=find(bbim); % wspolrzedne punktow

figure;
mbim = bwmorph(cbim, 'shrink', 10);
subplot(2,2,1);
imshow(mbim);
title("bwmorph - shrink, 10");

mbim = bwmorph(cbim, 'shrink', Inf); % zostana kropki tam gdzie byly obiekty
subplot(2,2,2); % erozja - ale zachowa liczbe eulera - i piksel tam gdzie na pewno nalezal do obiektu
imshow(mbim);
title("bwmorph - shrink, Inf");

% obraz ma liczbe eulera = liczba obiektow - liczba dziur w obiektach
% mozna przeksztalcic w inny obraz o tej samej liczbie eulera
% z topologicznego punktu widzenia to ten sam obiekt

% mbim = bwmorph(cbim, 'thin', 1);
% subplot(2,2,3);
% imshow(mbim);

mbim = bwmorph(cbim, 'thin', Inf); % thin do lini (grubosc 1 piksela) nie do punktu - zachowujemy ksztalt
subplot(2,2,3);
imshow(mbim);
title("bwmorph - thin, Inf");

mbim = bwmorph(cbim, 'thicken', Inf); % pogrubiamy ale tak zeby sie nie polaczyly
subplot(2,2,4); % zachowuje liczbe eulera
imshow(mbim); % 3 obszary gdzie w kazdym dokladnie 1 obiekt
title("bwmorph - thicken");

saveas(gcf, 'zdj3.jpg');

figure;
l = bwlabel(cbim); % macierz gdzie wartosci polaczone 1 - obiekt 1, polaczone 2 - obiekt 2 itd.
subplot(2,2,1);
imshow(l==2); % kaczka nr 2
title("l==2 - kaczka nr. 2");
% n = max(l); % maksimum - ilosc kaczek

subplot(2,2,2);
imshow(label2rgb(l)); % przypisuje kolory do etykiet
title("label2rgb");

subplot(2,2,3);
imshow(imc.*(l==2)); % przywracamy kolory tam gdzie kaczka nr. 2
title("kaczka nr. 2 w kolorach");

l = bwlabel(mbim);
subplot(2,2,4);
imshow(imc.*(l==2).*mbim);
title("kaczka nr. 2 obszar w kolorach");

saveas(gcf, 'zdj4.jpg');

% imc - kolory, l - logiczny podzial, cbim - ksztalty   - mozna je dowolnie
% laczyc

figure;
d = bwdist(cbim); % transformata odleglosciowa
subplot(2,2,1);
imshow(d, [0, max(d(:))]); % im dalej od kaczki tym jasniej (odwrocone cbim - bylby szkielet)
title("transformata odleglosciowa");

cbim([1,end], :) = 1;
cbim(:, [1,end]) = 1; % robimy sztuczna ramke
d = bwdist(cbim); % do otoczenia przypisana wartosc - odleglosc od najblizszej kaczki
subplot(2,2,2);
imshow(d, [0, max(d(:))]);
title("transformata odleglosciowa i sztuczna ramka");

% segmentacja wododzialowa - rozdzielamy tam gdzie granicy zlewsik

l = watershed(d);
subplot(2,2,3);
imshow(label2rgb(l)); % 4 obiekt bo jest ta ramka (ktora dodalismy)
title("watershed, label2rgb");

subplot(2,2,4);
imshow((l==3).*imc);
title("watershed, obszar nr. 3 w kolorach");

saveas(gcf, 'zdj5.jpg');

% metryka L2 (euklidesowa - domyslna dla bwdist) - odleglosc miedzy 2 punktami (z pitagorasa)
% L inf (czebyszewa)

figure;
d = bwdist(cbim, 'cityblock');
subplot(2,2,1);
imshow(d, [0, max(d(:))]);
title("transformata odleglosciowa, cityblock");

d = bwdist(cbim, 'chessboard'); % bardziej prostokatne krawedzie
subplot(2,2,2);
imshow(d, [0, max(d(:))]);
title("transformata odleglosciowa, chessboard");

d = bwdist(cbim, 'euclidean'); % niezalezne od ukladu odniesienia
subplot(2,2,3);
imshow(d, [0, max(d(:))]);
title("transformata odleglosciowa, euclidean");

saveas(gcf, 'zdj6.jpg');