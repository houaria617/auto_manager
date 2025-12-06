// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Auto Manager';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get cancel => 'Annuler';

  @override
  String get add => 'Ajouter';

  @override
  String get save => 'Enregistrer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get error => 'Erreur';

  @override
  String get required => 'Requis';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get navDashboard => 'Tableau de bord';

  @override
  String get navRentals => 'Locations';

  @override
  String get navCars => 'Voitures';

  @override
  String get navClients => 'Clients';

  @override
  String get navAnalytics => 'Analytique';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get agencyInfo => 'Infos agence';

  @override
  String get agencyInfoSubtitle => 'Mettre à jour les détails.';

  @override
  String get appLanguage => 'Langue';

  @override
  String get appLanguageSubtitle => 'Changer la langue.';

  @override
  String get subscription => 'Abonnement';

  @override
  String get subscriptionPlan => 'Plan actuel : Gratuit';

  @override
  String get rentalsTitle => 'Locations';

  @override
  String get tabOngoing => 'En cours';

  @override
  String get tabCompleted => 'Terminé';

  @override
  String get noRentalsOngoing => 'Aucune location en cours';

  @override
  String get noRentalsCompleted => 'Aucune location terminée';

  @override
  String get newRental => 'Nouvelle Location';

  @override
  String get rentalDetails => 'Détails';

  @override
  String get renewRental => 'Renouveler';

  @override
  String get returnCar => 'Retourner';

  @override
  String get managePayments => 'Paiements';

  @override
  String get viewPaymentHistory => 'Historique';

  @override
  String get rentalSummary => 'Résumé';

  @override
  String get rentalPeriod => 'Période';

  @override
  String get daysLeft => 'jours restants';

  @override
  String get daysOverdue => 'jours de retard';

  @override
  String get addRentalTitle => 'Nouvelle Location';

  @override
  String get selectClient => 'Sélectionner Client';

  @override
  String get selectCar => 'Sélectionner Voiture';

  @override
  String get startDate => 'Date début';

  @override
  String get endDate => 'Date fin';

  @override
  String get totalPrice => 'Prix Total';

  @override
  String get saveRental => 'Enregistrer';

  @override
  String get paymentsTitle => 'Paiements';

  @override
  String get remainingBalance => 'Reste à payer';

  @override
  String get totalPaid => 'Total Payé';

  @override
  String get balanceDue => 'Solde Dû';

  @override
  String get addPayment => 'Ajouter un paiement';

  @override
  String get enterAmount => 'Entrer le montant';

  @override
  String get pay => 'Payer';

  @override
  String get paymentHistory => 'Historique des transactions';

  @override
  String get analyticsTitle => 'Rapports';

  @override
  String get totalRevenue => 'Revenu Total';

  @override
  String get totalRentals => 'Total Locations';

  @override
  String get avgDuration => 'Durée Moyenne';

  @override
  String get topCars => 'Top Voitures';

  @override
  String get clientStats => 'Statistiques Clients';

  @override
  String get exportPdf => 'Exporter PDF';

  @override
  String get client => 'Client';

  @override
  String get car => 'Voiture';

  @override
  String get selectDate => 'Sélectionner la date';

  @override
  String get pleaseSelectDates =>
      'Veuillez sélectionner les dates de début et de fin';

  @override
  String get pleaseSelectClient => 'Veuillez sélectionner un client';

  @override
  String get pleaseSelectCar => 'Veuillez sélectionner une voiture';

  @override
  String get pleaseEnterPrice => 'Veuillez entrer le prix';

  @override
  String get invalidNumber => 'Nombre invalide';

  @override
  String get addNewClient => 'Ajouter un nouveau client';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom de famille';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get addNewCar => 'Ajouter une nouvelle voiture';

  @override
  String get carNameModel => 'Nom de la voiture (Modèle)';

  @override
  String get plateNumber => 'Numéro de plaque';

  @override
  String get dailyRentPrice => 'Prix de location quotidien';

  @override
  String get dateError =>
      'La date de fin doit être après ou égale à la date de début';

  @override
  String pricePerDay(String price) {
    return '$price/jour';
  }

  @override
  String rentalId(String id) {
    return 'ID Location: $id';
  }

  @override
  String get rentalNoLongerExists => 'Cette location n\'existe plus.';

  @override
  String get upgradeToPremium => 'Passer à Premium';

  @override
  String get free => 'Gratuit';

  @override
  String get zeroDA => '0DA';

  @override
  String get accessBasicFeatures => 'Accéder aux fonctionnalités de base';

  @override
  String get limitedRentals => 'Entrées de location limitées (10 max)';

  @override
  String get limitedCars => 'Entrées de voitures limitées (10 max)';

  @override
  String get premium => 'Premium';

  @override
  String get premiumPrice => '5999DA / mois';

  @override
  String get accessAllFeatures => 'Accéder à toutes les fonctionnalités';

  @override
  String get unlimitedRentals => 'Entrées de location illimitées';

  @override
  String get unlimitedCars => 'Entrées de voitures illimitées';

  @override
  String get rentalHistoryAnalytics => 'Historique et analyses de location';

  @override
  String get customReminders => 'Rappels personnalisés pour les clients';

  @override
  String get recommended => 'Recommandé';

  @override
  String get returnCarComplete => 'Retourner la voiture (Terminer)';

  @override
  String get rentalCompleted => 'Location terminée';

  @override
  String get extendRentalDuration => 'Prolonger la durée de location.';

  @override
  String get additionalDays => 'Jours supplémentaires';

  @override
  String get days => 'jours';

  @override
  String get estimatedDailyRate => 'Tarif journalier estimé:';

  @override
  String get extraCost => 'Coût supplémentaire:';

  @override
  String get confirmRenew => 'Confirmer le renouvellement';

  @override
  String renewedSuccess(int days, String amount) {
    return 'Renouvelé pour $days jours. Ajouté \$$amount au total.';
  }

  @override
  String errorRenewing(String error) {
    return 'Erreur lors du renouvellement de la location: $error';
  }

  @override
  String get statusOngoing => 'EN COURS';

  @override
  String get statusCompleted => 'TERMINÉ';

  @override
  String get statusOverdue => 'EN RETARD';

  @override
  String rentalIdLabel(String id) {
    return 'ID Location: $id';
  }

  @override
  String clientNumber(String id) {
    return 'Client #$id';
  }

  @override
  String carNumber(String id) {
    return 'Voiture #$id';
  }

  @override
  String get viewClient => 'Voir le client';

  @override
  String get viewCar => 'Voir la voiture';

  @override
  String get noPhoneInfo => 'Aucune info téléphone';

  @override
  String get unknownPlate => 'Plaque inconnue';

  @override
  String rentalIdColon(int id) {
    return 'ID Location: $id';
  }

  @override
  String daysLabel(int days) {
    return '$days jours';
  }

  @override
  String get start => 'Début';

  @override
  String get end => 'Fin';

  @override
  String get ongoingRentals => 'Locations en cours';

  @override
  String get availableCars => 'Voitures disponibles';

  @override
  String get dueToday => 'Échéance aujourd\'hui';

  @override
  String get recentActivities => 'Activités récentes';

  @override
  String carRentedBy(String plate, String client) {
    return 'Voiture $plate louée par $client';
  }

  @override
  String get revenue => 'Revenu';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get thisMonth => 'Ce mois';

  @override
  String get allTime => 'Tout le temps';

  @override
  String get custom => 'Personnalisé';

  @override
  String get totalClients => 'Total Clients';

  @override
  String get newClients => 'Nouveaux Clients';

  @override
  String get repeatClients => 'Clients récurrents';

  @override
  String get generatingPdf => 'Génération du rapport PDF...';

  @override
  String errorGeneratingPdf(String error) {
    return 'Erreur lors de la génération du PDF: $error';
  }

  @override
  String get pleaseWaitForData =>
      'Veuillez attendre le chargement des données.';
}
