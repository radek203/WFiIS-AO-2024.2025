clear; clc; close all;

im = imread('opera.jpg');
im = double(im) / 255;
im = rgb2gray(im);

figure;
subplot(2,2,1);
imshow(im);
title('Oryginalne zdjecie');

% Transformacja - operacja
% Transformata - wynik operacji

% f(x) = sum(yi*fi(x)) - fi(x) - ciagle z wartoscia 0, dla i wartosc 1, w
% transformacie (fouriera) zmieniamy te funkcje

% A [0,+inf)    w [-pi,pi)
% z = a+ib    z = Aexp(iw)     z = A(cosw + isinw)     A = sqrt(a*a + b*b)
% = |z|    w = arctg(b/a)

fim = fft2(im);
A = abs(fim); % amplituda |z|
omega = angle(fim); % faza

subplot(2,2,2);
% imshow(A, [0, max(A, [], 'all')]); % dodajemy zakres wartosci

imshow(fftshift(log(A)), [0, log(max(A, [], 'all'))]); % fftshift - zamienia  cwiartki miejscami
title('A - po zamianie cwiartek');
% te pixele co sa w srodku obrazu najwiecej wnosza do obrazu (niskie
% czestotliwosci)
% poziome kreski mowia o tym ile poziomych (??) linii na obrazie, pionowe
% ile pionowych itd.

z = A .* exp(1i*omega);
im2 = abs(ifft2(z));
subplot(2,2,3);
imshow(im2);
title('Po odwrotnej transformacie');

saveas(gcf, 'zdj12.jpg');

%A(5,5)=10^5;
%z = A .* exp(1i*omega);
%im2 = abs(ifft2(z));
%subplot(2,2,3);
%imshow(im2);

%A(5,1)=10^5; % jak jakis indeks 1 to fala pionowa/pozioma
%z = A .* exp(1i*omega);
%im2 = abs(ifft2(z));
%subplot(2,2,4);
%imshow(im2);

figure;
subplot(2,2,1);
imshow(omega, [-pi, pi]); % faza mowi gdzie dana funkcja sie znajduje, faza pomaga jezeli jest cos nietypowego takto 'losowa'
title('Omega [-pi,pi]');

k = 11;
f = ones(k) / k^2;
[h,w] = size(im);
ff = fft2(f, h, w); % chcemy filtr w rozmiarach obrazka
fA = abs(ff); % amplituda filtra
fomega = angle(ff); % faza filtra

subplot(2,2,2);
imshow(log(fA), [log(min(fA(:))), log(max(fA(:)))]); % 11x11 prostokatow
title('A Filtru');

subplot(2,2,3);
imshow(fomega, [-pi,pi]);
title('Omega Filtru [-pi,pi]');

z = A .* fA .* exp(1i*omega);
im2 = abs(ifft2(z));
subplot(2,2,4);
imshow(im2); % rozmyty obrazek, filtrowanie szybsze w dziedzinie czestotliwosciowej
title('Zdjecie po filtrze (rozmycie)');

saveas(gcf, 'zdj13.jpg');

m = zeros(h, w); % maska z zerami
k = 50;
m([1:k,end-k:end], [1:k,end-k:end]) = 1; % wycianmy to co nie potrzebne - kompresja

figure;
subplot(2,1,1);
imshow(m);
title('Maska z wycietymi rogami');

z = A .* m .* exp(1i*omega);
im2 = abs(ifft2(z));
subplot(2,1,2);
imshow(im2);
title('Zdjecie po nalozonej masce');

saveas(gcf, 'zdj14.jpg');
