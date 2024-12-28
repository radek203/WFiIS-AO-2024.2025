clear; clc; close all; % close all - zamyka wszystkie okna

im = imread('zubr.jpg'); % uint8, 642x1000x3
imshow(im);

im = double(im) / 255; % przy double chcemy od 0-1, robimy normalizacje, matlab woli double
% figure; % nowe okno do wyswietlania

subplot(2,2,1); % dzielimy pole rysowania na obszar 2x2 i rysujemy po 1 polu
imshow(im);
title('Oryginalne zdjecie');

subplot(2,2,2);
r = im;
r(:,:,[2,3]) = 0; % zerujemy wszystko co nie jest czerwone
imshow(r);
title('Wyzerowane wszystko z wyjatkiem czerwonego');

subplot(2,2,3);
g = im;
g(:,:,[1,3]) = 0; % zerujemy wszystko co nie jest zielone
imshow(g);
title('Wyzerowane wszystko z wyjatkiem zielonego');

subplot(2,2,4);
b = im;
b(:,:,[1,2]) = 0; % zerujemy wszystko co nie jest niebieskie
imshow(b);
title('Wyzerowane wszystko z wyjatkiem niebieskiego');

saveas(gcf, 'zdj1.jpg');

figure;
subplot(2,2,1);
imshow(im(:,:,1)); % jak mamy tylko 1 warstwe to jest to obrazek w odcieniach szarosci
title('Tylko 1 warstwa');
subplot(2,2,2);
imshow(r(:,:,1));
title('Tylko 1 warstwa (czerwona)');
subplot(2,2,3);
imshow(g(:,:,2));
title('Tylko 1 warstwa (zielona)');
subplot(2,2,4);
imshow(b(:,:,3));
title('Tylko 1 warstwa (niebieska)');

saveas(gcf, 'zdj2.jpg');

% zeby zmierzyc jasnosc obrazu mozna zrobic histogram

figure;
subplot(3,2,1);
imshow(r(:,:,1));
title('Tylko 1 warstwa (czerwony)');
subplot(3,2,2);
imhist(r(:,:,1)); % wszystkich wartosci mniej wiecej tyle samo
title('Histogram');

subplot(3,2,3);
imshow(g(:,:,2));
title('Tylko 1 warstwa (zielony)');
subplot(3,2,4);
imhist(g(:,:,2)); % od polowy w lewo zubr, w prawo trawa
title('Histogram');

subplot(3,2,5);
imshow(b(:,:,3));
title('Tylko 1 warstwa (niebieski)');
subplot(3,2,6);
imhist(b(:,:,3)); % nie ma jasnych pixeli, ale w miare jednolity
title('Histogram');

saveas(gcf, 'zdj3.jpg');

figure;
subplot(2,2,1);
imshow(im);
title('Oryginalne zdjecie');
subplot(2,2,2);
gim = mean(im, 3); % usredniamy ale w kierunku 3, obraz w odcieniach szarosci
imshow(gim);
title('Odcienie szarosci (mean)');

% standard yuv, konwersja do odcieni szarosci -> wagi dla kolorow: r - 0.299,
% g - 0.587, b - 0.114

yuv = [.299, .587, .114];
yuv = permute(yuv, [1,3,2]); % zamieniamy 1 z 3 wymiarem

subplot(2,2,3);
imshow(sum(im .* yuv, 3)); % przez te wagi, troche wiecej zielonego - troche jasniejszy
title('Odcienie szarosci (yuv)');

gim = rgb2gray(im); % dokladnie to samo co sami liczylismy
subplot(2,2,4);
imshow(gim);
title('Odcienie szarosci (rgb2gray)');

saveas(gcf, 'zdj4.jpg');

b = 0.2; % b (-1,1), neutralna 0
bim = gim + b; % rozjasniamy obrazek o 0.2 (lepiej widac na odcieniach szarosci)
bim(bim>1)=1;
bim(bim<0)=0;

figure;
subplot(3,2,1);
imshow(gim);
title('Odcienie szarosci (rgb2gray)');
subplot(3,2,2);
imhist(gim);
title('Histogram');

subplot(3,2,3);
imshow(bim);
title('Odcienie szarosci Zmiana Jasnosci b=0.2');
subplot(3,2,4);
imhist(bim); % histogram przesuniety o 0.2 w prawo..., wszystko od 0.8 w gore jest teraz = 1 (peak)
title('Histogram');

x = 0:1/255:1;
y = x + b;
y(y>1) = 1;
y(y<0) = 0;
subplot(3,2,5);
plot(x,y);
%subplot(3,2,6);
ylim([0,1]);

saveas(gcf, 'zdj5.jpg');

% kontrast - odleglosc miedzy wartosciami

c = 0.5; % c (0,+inf), neutralna 1, suwak - (0,1,255) - trzeba logarytm przedzial 0,1 mniejszy...
cim = gim * c;
cim(cim>1) = 1;
cim(cim<0) = 0;

figure;
subplot(3,2,1);
imshow(gim);
title('Odcienie szarosci (rgb2gray)');
subplot(3,2,2);
imhist(gim);
title('Histogram');

subplot(3,2,3);
imshow(cim);
title('Odcienie szarosci Zamiana Kontrastu c=0.5');
subplot(3,2,4);
imhist(cim); % histogram scisniety 2 razy (dla c = 2 bylby rozciagniety)
title('Histogram');

x = 0:1/255:1;
y = x * c;
y(y>1) = 1;
y(y<0) = 0;
subplot(3,2,5);
plot(x,y);
%subplot(3,2,6);
ylim([0,1]);

saveas(gcf, 'zdj6.jpg');

% gamma

g = 0.5; % g (0,+inf), neutralna 1
gaim = gim .^(1/g);

figure;
subplot(3,2,1);
imshow(gim);
title('Odcienie szarosci (rgb2gray)');
subplot(3,2,2);
imhist(gim);
title('Histogram');

subplot(3,2,3);
imshow(gaim);
title('Odcienie szarosci Zmiana Gammy g=0.5');
subplot(3,2,4);
imhist(gaim); % zmniejszylismy kontrast ciemnej czesci, a zwiekszylismy jasnej
title('Histogram');

x = 0:1/255:1;
y = x .^ (1/g);
y(y>1) = 1;
y(y<0) = 0;
subplot(3,2,5);
plot(x,y);
%subplot(3,2,6);
ylim([0,1]);

saveas(gcf, 'zdj7.jpg');
