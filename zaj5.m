clear; clc; close all;

im = imread('ptaki.jpg');
im = double(im) / 255;

figure;
subplot(3,2,1);
r = im;
g = im;
b = im;
r(:,:,[2,3])=0;
imshow(r);
title("Kanal czerwony")

subplot(3,2,2);
imhist(r);
title("Histogram")

g(:,:,[1,3])=0;
subplot(3,2,3);
imshow(g);
title("Kanal zielony")

subplot(3,2,4);
imhist(g);
title("Histogram")

b(:,:,[1,2])=0;
subplot(3,2,5);
imshow(b);
title("Kanal niebieski")

subplot(3,2,6);
imhist(b);
title("Histogram")

saveas(gcf, 'zdj7.jpg');

% zwykla binaryzacja nie dokladna - gradient, szukamy w kolorach
r = imbinarize(im(:,:,1));
b = imbinarize(im(:,:,3));

figure;
bim = r|~b; % czesc wspolna?
bim = imclose(bim, ones(7));
bim = imopen(bim, ones(7));
subplot(2,2,1);
imshow(bim);
title("Wyodrebione i Wypelnione Kaczki")

l = bwlabel(bim);

subplot(2,2,2);
imshow(label2rgb(l));
title("label2rgb")

a = regionprops(l==4, 'all');
% area - pole (w pikselach)
% centroid - srodek masy - uogolnienie sr arytmetycznej
% boundingbox - prostakat w ktorym zamknieta ta kaczka
% majoraxis - nadlusza dlugosc osi
% minoraxis - najkrotsza dlugosc osi
% eccentricity - miara odleglosci jak daleko od srodka, srodek masy
% orientation - jak nachylone
% convex - przy 3 wymiarach ma znaczenie
% circularity - jak bardzo podobny do kola
% Image - obraz przyciety do bounding boxa
% FilledImage - obraz z wypelnionymi dziurami
% FilledArea - powierzchnia po wypelnieniu dziur
% euler num - ile obiektow - liczba dziur
% extrema - wsp najbardziej wychylonych wartosci
% eqivdemeter - wazny przy circularity - srednica kola o polu naszej kaczki
% solidity - ile bialego wypelnia calego boundingboxa
% perimeter - obwod - lepsze oszacowanie
% perimeterold - obwod - na skos pierw z 2
% osie ferety - boki boundingboxa - jak inaczej (obiekt) obrocony co innego wyjdzie

% zawsze chcemy punkt odniesienia - dla statystyk jak porownujemy - mozna
% do kola

subplot(2,2,3);
imshow(a.Image);
title("Obiekt nr. 4 Przycięty do BoundingBoxa")

subplot(2,2,4);
imshow(l==4);
title("Tylko Obiekt nr. 4")

saveas(gcf, 'zdj8.jpg');

% kolo co ma taka sama powierzchnie (Ra  = sqrt (A/pi))
% kolo co ma taki sam obwod (Rl = L / 2pi)
% nie zalezRMalinowska;ne od skali - (Ra / Rl) - wsp kolowosci - circularity (0,1]
% (Rl / Ra - 1) - wsp malinowskiej [0, +inf)
% srednia odleglosc kazdego punktu od srodka masy , stosunek dla obiektu i
% dla kola ( o tym samym polu) - wsp. Blaira-Blissa
% tylko srednia odleglosc krawedzi od srodka masy - stosunek dla obiektu i dla
% kola - wsp. Daniellsona
% srednia odleglosc pikseli od krawedzi - dla obiektu i dla kola - wsp.
% Haralicka - bwdist(~a
% wsp ferreta f1/f2 - nie jest zalezne od skali - w ktora strone sa
% zorientowane obiekty

% w wierszach gesi - a w kolumnach kolejne wspolczynniki

f = {@AO5RBlairBliss, @AO5RCircularityL, @AO5RCircularityS, @AO5RDanielsson, @AO5RFeret, @AO5RHaralick, @AO5RMalinowska, @AO5RShape};

M = zeros(max(l(:)), length(f));
for i=1:max(l(:))
    for j=1:length(f)
        M(i, j) = f{j}(l==i);
    end
end

% zaj 6

% srednia, odchylenie standardowe
mp = mean(M);
sg = std(M);
c = abs(M - mp) ./ sg; % 99.7% wartosci w odl 3 sigm
% jak wychodzi za 3 sigm, to zakladamy ze nie jest to ges
% bedziemy po kolei wyrzucac gesi, liczyc c i znajdziemy ta co odstaje
% metoda Lin's one out
for i=1:8
    tM=M;
    tM(i,:)=[];
    mg = mean(tM);
    sg = std(tM);
    c(i,:)=abs(M(i,:)-mg) ./ sg; % widac ze dla 8 gesi duzo wieksze wartosci niz 3 sigm
end

test = sum(c>3, 2) > 1; % sumujemy (2 wymiar) tam gdzie sigma wieksza od 3, macierz logiczna ze 8 nie pasuje - wartosc 1
idx = find(test);

l(l==idx)=0; % wyrzucamy ges nr. 8
% trzeba od nowa policzyc etykiety, ilosc obiektow
bim = l>0;
l=bwlabel(bim);
n=max(l(:));

% obliczamy ponownie
M = zeros(max(l(:)), length(f));
for i=1:max(l(:))
    for j=1:length(f)
        M(i, j) = f{j}(l==i);
    end
end


im2 = imread('ptaki2.jpg');
im2 = double(im2) / 255;

bim2 = ~imbinarize(im2(:,:,3));

figure;
subplot(1,2,1);
imshow(bim2);
title("Jaskolki zbinaryzowane")

bim2 = imclose(bim2, ones(5));
bim2 = imopen(bim2, ones(5));
subplot(1,2,2);
imshow(bim2);
title("Jaskolki zbinaryzowane + close i open")

saveas(gcf, 'zdj9.jpg');

l2 = bwlabel(bim2);

for i=1:max(l2(:))
    if sum(l2==i, 'all') < 1000
        l2(l2==i)=0; % pozbywamy sie jaskolek przy krwedziach (maja mniejsze pole)
    end
end

l2 = bwlabel(l2>0);
n2 = max(l2(:));


M2 = zeros(max(l2(:)), length(f));
for i=1:max(l2(:))
    for j=1:length(f)
        M2(i, j) = f{j}(l2==i);
    end
end

% x -> f -> y
%          1 warstwa                                          2 warstwa itd.
% x1*w1    suma... funkcja Sigmoidalna -1, 1 -> q1*u1                     suma... funkcja liniowa -> y1
% x2*w2    suma (z innymi wagami)... funkcja Sigmoidalna -1, 1 -> q1*u2      
% x3*w3

% proces dobierania wag - tak zeby dla naszych danych gdzie wiemy co
% wyjdzie wyszlo np. ges/jaskolka - trenowanie sieci

% dane na ktorych bedziemy uczyc
ug = M(1:end-2,:)'; % 8x5
uj = M2(1:end-2,:)'; % 8x4
% zestaw testowy
tg = M(end-1:end,:)'; % 8x2
tj = M2(end-1:end,:)'; % 8x2

u0 = [ones(1, n-2), zeros(1, n2-2)]; % [111110000]

nn = feedforwardnet; % tworzy siec neuronowa
nn = train(nn,[ug, uj], u0); % uczymy danymi

nn(M(1,:)')
nn([tg, tj])
