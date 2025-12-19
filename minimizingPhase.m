clear; clc;

k = 50;
w_min = 0;
w_max = pi;

n = linspace(0, 10*k, 10*k+1);
impulse = zeros(10*k+1, 1);
impulse(1) = 1;

%% Unstable System
%
% Goal: Achieve a zero-phase filter.
% Outcome: Ended up with an unstable system. 
%
% Filter-Type: Zero-phase (impossible).
%
% We have a completely real frequency response, and the
% system is causal. However, we have unstable poles (poles that are on or
% outside the unit circle).

b = zeros(2*k+1, 1);
b(end) = 4;
a = zeros(4*k+1, 1);
a(1) = 1;
a(ceil(2*k + 1/2)) = 6;
a(end) = 1;

Gpoles = roots(a);

[g, w] = freqz(b, a, linspace(w_min, w_max, 5000));

fig1 = figure(Theme="light");
subplot(2, 1, 1);
plot(w, 20*log10(abs(g)));
xlim([w_min w_max])
xlabel('Frequency (rad/sample)');
ylabel('Gain (dB)');
title('Magnitude Response');
grid on;

gphase = angle(g);
gphase(abs(gphase) < 1e-3) = 0;
subplot(2, 1, 2);
plot(w, gphase/pi);
xlim([w_min w_max])
xlabel('Frequency (rad/sample)');
ylabel('Normalized Phase (Phase/\pi)');
title('Phase Response');
grid on;

fig2 = figure(Theme="light");
zplane(b', a');

saveas(fig1, "Results/ZeroPhaseFilter.png");
saveas(fig2, "Results/ZeroPhasePoleZeroPlot.png");

%% Stable System (by cancelling poles)
%
% Goal: Stablize the system.
% Outcome: Achieved a stable system at the cost of latency. 
%
% Filter-Type: Linear-Phase.
%
% We achieved the same shape for our magnitude response,
% but introduce a substantial phase delay.

b = zeros(4*k+1, 1);
b(2*k+1) = 4;
b(end) = 4*(3 + 2*sqrt(2));
a = zeros(4*k+1, 1);
a(1) = 1;
a(ceil(2*k + 1/2)) = 6;
a(end) = 1;

Hpoles = roots(a);

[h, w] = freqz(b, a, linspace(w_min, w_max, 2000));

fig3 = figure(Theme="light");
subplot(2, 1, 1);
plot(w, 20*log10(abs(h)));
xlim([w_min w_max])
xlabel('Frequency (rad/sample)');
ylabel('Gain (dB)');
title('Magnitude Response');
grid on;

hphase = angle(h);
hphase(abs(hphase) < 1e-3) = 0;
subplot(2, 1, 2);
plot(w, hphase/pi);
xlim([w_min w_max])
xlabel('Frequency (rad/sample)');
ylabel('Normalized Phase (Phase/\pi)');
title('Phase Response');
grid on;

fig4 = figure(Theme="light");
zplane(b', a');

fig4b = figure(Theme="light");
y = filter(b, a, impulse);
stem(n, y);
title("Impulse Response of Linear Phase Filter");
ylabel("Amplitude");
xlabel("Time (sample)");

saveas(fig3, "Results/LinearPhaseFilter.png");
saveas(fig4, "Results/LinearPhasePoleZeroPlot.png");
saveas(fig4b, "Results/LinearPhaseImpulse.png");

%% Stable System (by reconstruction)
%
% Goal: Minimize the phase.
% Outcome: Minimized phase to be within the range of about +-5% of pi. 
%
% Filter-Type: Minimum-Phase.
%
% We minimized the phase delay by reconstructing the system from only
% stable poles. This both removes the unstable poles and the zeros used to
% cancel out those poles. The zeros we had earlier introduced a significant
% phase delay since they represent physical delays.

b = 1;
a = zeros(2*k+1, 1);
a(1) = 1;
a(end) = (3 - 2*sqrt(2));

Qpoles = roots(a);

[q, w] = freqz(b, a, linspace(w_min, w_max, 2000));

fig5 = figure(Theme="light");
title(["Stable Minimum Phase Filter (k =", num2str(k), ")"]);
subplot(2, 1, 1);
plot(w, 20*log10(abs(q)));
xlim([w_min w_max])
xlabel('Frequency (rad/sample)');
ylabel('Gain (dB)');
title('Magnitude Response');
grid on;

qphase = angle(q);
qphase(abs(qphase) < 1e-3) = 0;
subplot(2, 1, 2);
plot(w, qphase/pi);
xlim([w_min w_max])
xlabel('Frequency (rad/sample)');
ylabel('Normalized Phase (Phase/\pi)');
title('Phase Response');
grid on;

fig6 = figure(Theme="light");
zplane([], roots(a));

fig6b = figure(Theme="light");
y = filter(b, a, impulse);
stem(n, y);
title("Impulse Response of Minimum Phase Filter");
ylabel("Amplitude");
xlabel("Time (sample)");

saveas(fig5, "Results/MinimumPhaseFilter.png");
saveas(fig6, "Results/MinimumPhasePoleZeroPlot.png");
saveas(fig6b, "Results/MinimumPhaseImpulse.png");