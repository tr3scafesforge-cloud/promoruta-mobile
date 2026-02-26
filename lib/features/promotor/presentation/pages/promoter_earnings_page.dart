import 'package:flutter/material.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/core/constants/colors.dart';

class PromoterEarningsPage extends StatefulWidget {
  const PromoterEarningsPage({super.key});

  @override
  State<PromoterEarningsPage> createState() => _PromoterEarningsPageState();
}

class _PromoterEarningsPageState extends State<PromoterEarningsPage> {
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Earnings Card
              _EarningsCard(
                title: l10n.totalEarnings,
                amount: '\$2,847.50',
                subtitle: l10n.accumulated,
                icon: Icons.attach_money,
              ),
              const SizedBox(height: 12),

              // This Month Card
              _EarningsCard(
                title: l10n.thisMonth,
                amount: '\$547.50',
                subtitle: l10n.percentageMoreThanLastMonth('23.5'),
                subtitleColor: AppColors.green,
                icon: Icons.trending_up,
              ),
              const SizedBox(height: 12),

              // Available Card with Button
              _AvailableEarningsCard(l10n: l10n),
              const SizedBox(height: 16),

              // Pending Earnings Warning
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFE0B2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.pendingEarningsAmount('\$156.23'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.availableAfterCampaign,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Segmented Control
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentButton(
                        label: l10n.historical,
                        isSelected: _selectedSegment == 0,
                        onTap: () => setState(() => _selectedSegment = 0),
                      ),
                    ),
                    Expanded(
                      child: _SegmentButton(
                        label: l10n.statistics,
                        isSelected: _selectedSegment == 1,
                        onTap: () => setState(() => _selectedSegment = 1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Content based on selected segment
              if (_selectedSegment == 0) _HistoricoView(l10n: l10n),
              if (_selectedSegment == 1) _EstadisticasView(l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final Color? subtitleColor;
  final IconData icon;

  const _EarningsCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    this.subtitleColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grayLightStroke,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Icon(
                icon,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: subtitleColor ?? AppColors.textSecondary,
              fontWeight: subtitleColor != null ? FontWeight.w500 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableEarningsCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _AvailableEarningsCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grayLightStroke,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.available,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$5,473.50',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${l10n.withdrawFunds} (WIP)')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.withdrawFunds,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _HistoricoView extends StatelessWidget {
  final AppLocalizations l10n;

  _HistoricoView({required this.l10n});

  final List<EarningTransaction> transactions = [
    EarningTransaction(
      campaignName: 'Promoción Cafetería',
      promoterCompany: 'Promoter Company',
      date: '2025-02-15',
      amount: 48.20,
      status: 'Pagada',
      paymentMethod: 'Transferencia Bancaria',
    ),
    EarningTransaction(
      campaignName: 'Promoción Cafetería',
      promoterCompany: 'Promoter Company',
      date: '2025-02-15',
      amount: 148.20,
      status: 'Pendiente',
      paymentMethod: 'Paypal',
    ),
    EarningTransaction(
      campaignName: 'Promoción Supermercado',
      promoterCompany: 'Promoter Company',
      date: '2025-02-10',
      amount: 250.00,
      status: 'Pagada',
      paymentMethod: 'Transferencia Bancaria',
    ),
    EarningTransaction(
      campaignName: 'Promoción Bebidas',
      promoterCompany: 'Promoter Company',
      date: '2025-02-08',
      amount: 75.50,
      status: 'Pagada',
      paymentMethod: 'Paypal',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grayLightStroke,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  l10n.recentEarnings,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: TextButton.icon(
                  onPressed: () {
                    // Handle download report
                  },
                  icon: const Icon(Icons.download, size: 18),
                  label: Text(
                    l10n.downloadReport,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...transactions.map((transaction) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TransactionItem(transaction: transaction, l10n: l10n),
              )),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final EarningTransaction transaction;
  final AppLocalizations l10n;

  const _TransactionItem({required this.transaction, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPaid = transaction.status == 'Pagada';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.grayLightStroke,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.attach_money,
              color: AppColors.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.campaignName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.promoterCompany,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        transaction.date,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${transaction.amount.toStringAsFixed(2)}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid
                      ? AppColors.green.withValues(alpha: 0.1)
                      : AppColors.pendingOrangeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isPaid)
                      Icon(
                        Icons.check_circle,
                        size: 12,
                        color: AppColors.green,
                      ),
                    if (!isPaid)
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: AppColors.pendingOrangeColor,
                      ),
                    const SizedBox(width: 4),
                    Text(
                      isPaid ? l10n.paid : l10n.pending,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isPaid
                            ? AppColors.green
                            : AppColors.pendingOrangeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                transaction.paymentMethod,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EstadisticasView extends StatelessWidget {
  final AppLocalizations l10n;

  _EstadisticasView({required this.l10n});

  final List<MonthlyEarning> earnings = [
    MonthlyEarning('Ene', 485),
    MonthlyEarning('Dic', 432),
    MonthlyEarning('Nov', 380),
    MonthlyEarning('Oct', 520),
    MonthlyEarning('Sept', 290),
    MonthlyEarning('Ago', 410),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue =
        earnings.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grayLightStroke,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.earningsPerMonth,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.lastSixMonths,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ...earnings.map((earning) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _EarningBar(
                  month: earning.month,
                  amount: earning.amount,
                  maxValue: maxValue.toDouble(),
                ),
              )),
        ],
      ),
    );
  }
}

class _EarningBar extends StatelessWidget {
  final String month;
  final int amount;
  final double maxValue;

  const _EarningBar({
    required this.month,
    required this.amount,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = amount / maxValue;

    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            month,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.grayLightStroke,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 50,
          child: Text(
            '\$$amount',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class MonthlyEarning {
  final String month;
  final int amount;

  MonthlyEarning(this.month, this.amount);
}

class EarningTransaction {
  final String campaignName;
  final String promoterCompany;
  final String date;
  final double amount;
  final String status;
  final String paymentMethod;

  EarningTransaction({
    required this.campaignName,
    required this.promoterCompany,
    required this.date,
    required this.amount,
    required this.status,
    required this.paymentMethod,
  });
}
